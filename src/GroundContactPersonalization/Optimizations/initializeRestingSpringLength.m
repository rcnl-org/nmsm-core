% This function is part of the NMSM Pipeline, see file for full license.
%
% This optimization determines the ideal resting spring length for the 
% initial spring constants and experimental kinematics to match the 
% experimental vertical ground reaction force. This will not match well on 
% its own, but it will improve the performance of the next Ground Contact 
% Personalization stages. 
%
% (struct, struct) -> (struct)
% Initializes the resting spring length for Ground Contact Personalization.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function inputs = initializeRestingSpringLength(inputs)
for surface = 1:length(inputs.surfaces)
    [modeledJointPositions, modeledJointVelocities] = ...
        calcGCPJointKinematics( ...
        inputs.surfaces{surface}.experimentalJointPositions, ...
        inputs.surfaces{surface}.jointKinematicsBSplines, ...
        inputs.surfaces{surface}.bSplineCoefficients);
    modeledValues{surface}.springHeights = zeros(size(...
        modeledJointPositions, 2), length(inputs.springConstants));
    modeledValues{surface}.springVelocities = ...
        modeledValues{surface}.springHeights;

    % As this optimization only calibrates the resting spring length,
    % marker positions cannot change. 
    [model, state] = Model(inputs.surfaces{surface}.model);
    for i=1:size(modeledJointPositions, 2)
        [model, state] = updateModelPositionAndVelocity(model, state, ...
            modeledJointPositions(:, i), modeledJointVelocities(:, i));
        for j = 1:length(inputs.springConstants)
            modeledValues{surface}.springHeights(i, j) = ...
                model.getMarkerSet().get("spring_marker_" + num2str(j)) ...
                .getLocationInGround(state).get(1);
            modeledValues{surface}.springVelocities(i, j) = ...
                model.getMarkerSet().get("spring_marker_" + num2str(j)) ...
                .getVelocityInGround(state).get(1);
        end
    end
end

inputs.restingSpringLength = lsqnonlin( ...
    @(restingSpringLength) calcRestingSpringLengthCost( ...
    restingSpringLength, inputs, modeledValues), ...
    inputs.initialRestingSpringLength, [], []);
end

% Cost only depends on vertical ground reaction force tracking.
function cost = calcRestingSpringLengthCost(restingSpringLength, ...
    inputs, modeledValues)
cost = [];
for surface = 1:length(inputs.surfaces)
    verticalForce = ...
        inputs.surfaces{surface}.experimentalGroundReactionForces(2, :);
    modeledVerticalGrf = zeros(size(verticalForce));
    for i = 1:length(modeledVerticalGrf)
        for j = 1:length(inputs.springConstants)
            % The freglyVerticalGrf model closely approximates a linear 
            % spring during contact while allowing a small force with a 
            % small slope to exist for spring markers out of contact. This 
            % can help the optimization algorithm find a better search 
            % direction when springs are incorrectly out of contact.
            height = modeledValues{surface}.springHeights(i, j);
            velocity = modeledValues{surface}.springVelocities(i, j);
            klow = 1e-1;
            h = 1e-3;
            c = 5e-4;
            ymax = 1e-2;
            Kval = inputs.springConstants(j);
            height = height - restingSpringLength;
            numFrames = length(height);
            v = ones(numFrames, 1)' .* ((Kval + klow) ./ (Kval - klow));
            s = ones(numFrames, 1)' .* ((Kval - klow) ./ 2);
            constant = -s .* (v .* ymax - c .* log(cosh((ymax + h) ./ c)));
            freglyVerticalGrf = -s .* (v .* height - c .* ...
                log(cosh((height + h) ./ c))) - constant;
            freglyVerticalGrf(isnan(freglyVerticalGrf)) = ...
                min(min(freglyVerticalGrf));
            freglyVerticalGrf(isinf(freglyVerticalGrf)) = ...
                min(min(freglyVerticalGrf));
            modeledVerticalGrf(i) = modeledVerticalGrf(i) + ...
                freglyVerticalGrf * (1 + inputs.dampingFactor * ...
                velocity);
        end
    end
    cost = [cost sqrt(1 / length(verticalForce)) * ...
        (verticalForce - modeledVerticalGrf)];
end
end

function [model, state] = updateModelPositionAndVelocity(model, state, ...
    jointPositions, jointVelocities)
for j=1:size(jointPositions, 1)
    model.getCoordinateSet().get(j-1).setValue(state, ...
        jointPositions(j));
    model.getCoordinateSet().get(j-1).setSpeedValue(state, ...
        jointVelocities(j));
end
model.assemble(state)
model.realizeVelocity(state)
end
