% This function is part of the NMSM Pipeline, see file for full license.
%
% This function loads the appropriate spring position and velocity
% directions to calculate the corresponding ground reaction forces and
% moments. The ground reaction forces and moments are calculated for both
% the parent (ex. calcaneus) and child body (ex. toes).
%
% (struct, struct, struct, struct) -> (struct)
% Returns ground reaction forces and moments at the parent and child body 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function groundReactions = calcFootGroundReactions(springPositions, ...
    springVelocities, params, bodyLocations)

for i = 1:length(params.contactSurfaces)
    contactSurface = params.contactSurfaces{i};
    
    if isfield(contactSurface, 'parentSpringIndices')
        parentIdx = contactSurface.parentSpringIndices;
    else
        parentIdx = [];
    end
    if isfield(contactSurface, 'childSpringIndices')
        childIdx = contactSurface.childSpringIndices;
    else
        childIdx = [];
    end

    [groundReactions.parentForces{i}, groundReactions.parentMoments{i}] = ...
        calcGroundReactionForcesAndMoments(springPositions.parent{i}, ...
        springVelocities.parent{i}, contactSurface.parentSpringConstants, ...
        bodyLocations.midfootSuperior{i}, contactSurface, parentIdx); 

    [groundReactions.childForces{i}, groundReactions.childMoments{i}] = ...
        calcGroundReactionForcesAndMoments(springPositions.child{i}, ...
        springVelocities.child{i}, contactSurface.childSpringConstants, ...
        bodyLocations.midfootSuperior{i}, contactSurface, childIdx); 
end
end

function [forces, moments] = calcGroundReactionForcesAndMoments(markerPositions, ...
    markerVelocities, springConstants, midfootSuperiorPosition, contactSurface, springIdx)
% opensim buildMeyerFregly2016Force version

midfootSuperiorPosition = squeeze(midfootSuperiorPosition);
nFrames = size(midfootSuperiorPosition, 1);  % one row per time step
task.midfootSuperiorPosition = midfootSuperiorPosition.';

forces = zeros(nFrames, 3);
moments = zeros(nFrames, 3);

if ~isempty(springIdx)
    import org.opensim.modeling.*
    global osimModel osimStates
    
    if isempty(osimModel) || isempty(osimStates)
        error('Global osimModel / osimStates not initialized.');
    end
    
    nSprings = numel(springIdx);     % springs on this surface

    for i = 1:nFrames
        state = osimStates{i};
        osimModel.realizeVelocity(state); 
    
        % build markerKinematics from OpenSim Stations
        pos_x = zeros(1, nSprings);
        height = zeros(1, nSprings);
        pos_z = zeros(1, nSprings);
        vel_x = zeros(1, nSprings);
        vel_y = zeros(1, nSprings);
        vel_z = zeros(1, nSprings);
    
        for k = 1:nSprings
            j = springIdx(k);  % map to full spring list
            springName = char(contactSurface.springs{j}.name);
    
            station  = Station.safeDownCast(osimModel.getComponent(springName));
            pos = station.getLocationInGround(state);
            vel = station.getVelocityInGround(state);
    
            pos_x(k) = pos.get(0);
            height(k)  = pos.get(1);
            pos_z(k) = pos.get(2);
    
            vel_x(k) = vel.get(0);
            vel_y(k) = vel.get(1);
            vel_z(k) = vel.get(2);
        end
        
        markerKinematics.xPosition = pos_x;
        markerKinematics.height = height;
        markerKinematics.zPosition = pos_z;
        markerKinematics.xVelocity = vel_x;
        markerKinematics.yVelocity = vel_y;
        markerKinematics.zVelocity = vel_z;

        matrix_opensim = [markerKinematics.xPosition;
            markerKinematics.height;
            markerKinematics.zPosition;
            markerKinematics.xVelocity;
            markerKinematics.yVelocity;
            markerKinematics.zVelocity];  
        
        springForces = zeros(3, nSprings);

        [forces(i, 2), springForces] = calcModeledVerticalGroundReactionForce( ...
            springConstants, contactSurface.dampingFactor, ...
            contactSurface.restingSpringLength, markerKinematics, springForces);
        
        contactSurface.springConstants = springConstants;
        
        [forces(i, 1), forces(i, 3), springForces] = ...
            calcModeledHorizontalGroundReactionForces(contactSurface, ...
            contactSurface.beltSpeed, contactSurface.latchingVelocity, ...
            markerKinematics, springForces);
        
        [moments(i, 1), moments(i, 2), moments(i, 3)] = ...
            calcModeledGroundReactionMoments(contactSurface, task, ...
            markerKinematics, springForces, i);
    end
else
    markerPositions = reshape(markerPositions, [], 3, size(springConstants, 2));
    markerVelocities = reshape(markerVelocities, [], 3, size(springConstants, 2));
    nSprings = size(springConstants, 2);
    
    for i = 1:nFrames
        markerKinematics.xPosition = squeeze(markerPositions(i, 1, :))';
        markerKinematics.height = squeeze(markerPositions(i, 2, :))';
        markerKinematics.zPosition = squeeze(markerPositions(i, 3, :))';
        markerKinematics.xVelocity = squeeze(markerVelocities(i, 1, :))';
        markerKinematics.yVelocity = squeeze(markerVelocities(i, 2, :))';
        markerKinematics.zVelocity = squeeze(markerVelocities(i, 3, :))';
    
        matrix_nmsm = [markerKinematics.xPosition;
            markerKinematics.height;
            markerKinematics.zPosition;
            markerKinematics.xVelocity;
            markerKinematics.yVelocity;
            markerKinematics.zVelocity];  

        springForces = zeros(3, nSprings);

        [forces(i, 2), springForces] = calcModeledVerticalGroundReactionForce( ...
            springConstants, contactSurface.dampingFactor, ...
            contactSurface.restingSpringLength, markerKinematics, springForces);
        
        contactSurface.springConstants = springConstants;
        
        [forces(i, 1), forces(i, 3), springForces] = ...
            calcModeledHorizontalGroundReactionForces(contactSurface, ...
            contactSurface.beltSpeed, contactSurface.latchingVelocity, ...
            markerKinematics, springForces);
        
        [moments(i, 1), moments(i, 2), moments(i, 3)] = ...
            calcModeledGroundReactionMoments(contactSurface, task, ...
            markerKinematics, springForces, i);
    end
end
end
