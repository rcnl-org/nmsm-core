% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
%

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

function inverseDynamicMoments = inverseDynamicsMatlabParallel(time, ...
    jointAngles, jointVelocities, jointAccelerations, coordinateLabels, ...
    appliedLoads, modelName)

% Get the number of coords and markers
numPts = size(time,1);
numControls = size(appliedLoads,2);
numCoords = length(coordinateLabels);
% Split time points into parallel problems
numWorkers = gcp().NumWorkers;
inverseDynamicJobs = cell(1, numWorkers);
accelsTempVec = cell(1, numWorkers);
parfor worker = 1:numWorkers
    inverseDynamicJobs{worker} = idWorkerHelper(modelName, numPts, ...
        numControls, numCoords, numWorkers, accelsTempVec{worker}, ...
        time, jointAngles, jointVelocities, jointAccelerations, ...
        coordinateLabels,appliedLoads,worker);
end
inverseDynamicMoments = inverseDynamicJobs{1};
for job = 2 : numWorkers
    inverseDynamicMoments = cat(1, inverseDynamicMoments, ...
        inverseDynamicJobs{job});
end
end
function inverseDynamicJobs = idWorkerHelper(modelName, numPts, ...
    numControls, numCoords, numWorkers, accelsTempVec, time, jointAngles, ...
    jointVelocities, jointAccelerations, coordinateLabels, appliedLoads, ...
    worker)
    
import org.opensim.modeling.*;
persistent osimModel;
persistent osimState;
persistent inverseDynamicsSolver;
if isempty(osimModel)
    osimModel = Model(modelName);
    osimState = osimModel.initSystem();
    inverseDynamicsSolver = InverseDynamicsSolver(osimModel);
end
inverseDynamicJobs = zeros(length(1 + (worker - 1) * ceil(numPts / numWorkers) : ...
    min(worker * ceil(numPts / numWorkers), numPts)), numCoords);
indexOffset = (worker - 1) * ceil(numPts / numWorkers);
for j = 1 + (worker - 1) * ceil(numPts / numWorkers) : min(worker * ceil(numPts / numWorkers), numPts)
    osimState.setTime(time(j,1));
    for k=1:size(coordinateLabels,2)
        if ~osimModel.getCoordinateSet.get(coordinateLabels{k}).get_locked
            osimModel.getCoordinateSet.get(coordinateLabels{k}). ...
                setValue(osimState,jointAngles(j, k));
            osimModel.getCoordinateSet.get(coordinateLabels{k}). ...
                setSpeedValue(osimState,jointVelocities(j, k));
        end
    end
    osimModel.realizeVelocity(osimState);
    for i=1:osimState.getNQ
        statePositions = osimState.getQ.get(i-1);
        for ii = 1:size(jointAngles,2)
            if abs(jointAngles(j, ii) - statePositions) <= 1e-6
                accelsTempVec(j - indexOffset, i) = jointAccelerations(j, ii);
            end
        end
    end
    newControls = Vector(numControls,0);
    for i=0 : numControls - 1
        newControls.set(i, appliedLoads(j, i + 1));
    end
    osimModel.setControls(osimState, newControls);
    osimModel.markControlsAsValid(osimState);
    osimModel.realizeDynamics(osimState);
    accelsVec = Vector(osimState.getNQ, 0);
    includedQIndex = 1;
    for i=0:osimState.getNQ-1
        currentCoordinate = osimModel.getCoordinateSet().get(i).getName().toCharArray';
        if any(cellfun(@isequal, coordinateLabels, repmat({currentCoordinate}, 1, length(coordinateLabels))))
            accelsVec.set(i, accelsTempVec(j - indexOffset, includedQIndex));
            includedQIndex = includedQIndex + 1;
        end
    end
    IDLoadsVec = inverseDynamicsSolver.solve(osimState,accelsVec);
    for i=0 : numCoords - 1
        inverseDynamicJobs(j - indexOffset, i + 1) = IDLoadsVec.get(i);
    end
end
end
