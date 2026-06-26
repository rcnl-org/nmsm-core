% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses OpenSim's Simbody engine to calculate the location 
% and velocities of the indicated point(s). Parallel workers are used to 
% speed up computational time.
% 
% (Array of number, 2D matrix, 2D matrix, 2D matrix (or Array of number), 
% Array of number (or number), Array of string, cell) -> (2D matrix, 2D matrix)
% Returns point positions and point velocities

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Marleny Vega                               %
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

function [pointPositions, pointVelocities] = ...
    pointKinematicsMatlabParallel(time, jointAngles, jointVelocities, ...
    pointLocationOnBody, body, modelName, coordinateNames)

% Get the number of coords and markers
numPts = size(time,1);
numSprings = size(pointLocationOnBody,1);
% Split time points into parallel problems
numWorkers = gcp().NumWorkers;
pointPositionsJobs = cell(1, numWorkers);
pointVelocitiesJobs = cell(1, numWorkers);
parfor worker = 1:numWorkers
    [pointPositionsJobs{worker}, pointVelocitiesJobs{worker}] = ...
        pointKinematicsWorkerHelper(modelName, numPts, numSprings, ...
        numWorkers, time, jointAngles, jointVelocities, ...
        pointLocationOnBody, body, coordinateNames, worker);
end
pointPositions = pointPositionsJobs{1};
pointVelocities = pointVelocitiesJobs{1};
for job = 2 : numWorkers
    pointPositions = cat(1, pointPositions, pointPositionsJobs{job});
    pointVelocities = cat(1, pointVelocities, pointVelocitiesJobs{job});
end
end

function [SpringPosJob, SpringVelJob] = ...
    pointKinematicsWorkerHelper(modelFile, numPts, numSprings, ...
    numWorkers, time, jointAngles, jointVelocities, pointLocationOnBody, ...
    body, coordinateNames, worker)

import org.opensim.modeling.*;
persistent osimModel;
persistent osimState;
persistent refBodySet;
if isempty(osimModel)
    osimModel = Model(modelFile);
    osimState = osimModel.initSystem();
    refBodySet = osimModel.getBodySet;
end
SpringPosJob = zeros(length(1 + (worker - 1) * ceil(numPts / numWorkers) : ...
    min(worker * ceil(numPts / numWorkers), numPts)), numSprings * 3);
SpringVelJob = zeros(length(1 + (worker - 1) * ceil(numPts / numWorkers) : ...
    min(worker * ceil(numPts / numWorkers), numPts)), numSprings * 3);
indexOffset = (worker - 1) * ceil(numPts / numWorkers);
for j = 1 + (worker - 1) * ceil(numPts / numWorkers) : min(worker * ceil(numPts / numWorkers), numPts)
    osimState.setTime(time(j,1));
    for k=1:size(coordinateNames,2)
        if ~osimModel.getCoordinateSet.get(coordinateNames{k}).get_locked
            %
            osimModel.getCoordinateSet.get(coordinateNames{k}). ...
                setValue(osimState,jointAngles(j,k), false);
            osimModel.getCoordinateSet.get(coordinateNames{k}). ...
                setSpeedValue(osimState,jointVelocities(j,k));
        end
    end
    osimModel.realizeVelocity(osimState);
    for i=1:numSprings
        tempRefParentBody = refBodySet.get(body(i));
        tempLocalPos = Vec3(3, 0);
        tempGlobalPos = Vec3(3, 0);
        tempGlobalVel = Vec3(3, 0);
        tempLocalPos.set(0,pointLocationOnBody(i, 1));
        tempLocalPos.set(1,pointLocationOnBody(i, 2));
        tempLocalPos.set(2,pointLocationOnBody(i, 3));
        osimModel.getSimbodyEngine.getPosition(osimState, ...
            tempRefParentBody, tempLocalPos, tempGlobalPos);
        osimModel.getSimbodyEngine.getVelocity(osimState, ...
            tempRefParentBody, tempLocalPos, tempGlobalVel);
        for k=0:2
            SpringPosJob(j - indexOffset, (i - 1) * 3 + k + 1) = ...
                tempGlobalPos.get(k);
            SpringVelJob(j - indexOffset, (i - 1) * 3 + k + 1) = ...
                tempGlobalVel.get(k);
        end
    end
end
end
