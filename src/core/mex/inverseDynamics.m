% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses a mex file or a matlab function with parallel workers
% to calculate inverse dynamics moments.
%
% This assumes muscleActivations matrix is in model muscle order
%
% (Array of number, 2D matrix, 2D matrix, 2D matrix, Cell, 2D matrix,
% Array of string) -> (2D matrix)
% Returns inverse dynamic moments

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

function [inverseDynamicsMoments, angularMomentum, metabolicCost, ...
    massCenterVelocity] = ...
    inverseDynamics( time, jointAngles, jointVelocities, ...
    jointAccelerations, coordinateLabels, appliedLoads, modelName, ...
    muscleActivations, computeAngularMomentum, computeMetabolicCost, ...
    version)
if isequal(mexext, 'mexw64')
    pool = gcp();
    numWorkers = pool.NumWorkers;

    index = 1;
    timeParts = cell(1, numWorkers);
    jointAnglesParts = cell(1, numWorkers);
    jointVelocitiesParts = cell(1, numWorkers);
    jointAccelerationsParts = cell(1, numWorkers);
    appliedLoadsParts = cell(1, numWorkers);
    muscleActivationsParts = cell(1, numWorkers);
    inverseDynamicsMomentsParts = cell(1, numWorkers);
    angularMomentumParts = cell(1, numWorkers);
    metabolicCostParts = cell(1, numWorkers);
    massCenterVelocityParts = cell(1, numWorkers);
    
    remainder = mod(length(time), numWorkers);
    for i = 1 : numWorkers
        if i <= remainder
            nextIndex = index - 1 + ceil(length(time) / numWorkers);
        else
            nextIndex = index - 1 + floor(length(time) / numWorkers);
        end
        timeParts{i} = time(index : nextIndex);
        jointAnglesParts{i} = jointAngles(index : nextIndex, :);
        jointVelocitiesParts{i} = jointVelocities(index : nextIndex, :);
        jointAccelerationsParts{i} = jointAccelerations(index : nextIndex, :);
        appliedLoadsParts{i} = appliedLoads(index : nextIndex, :);
        if ~isempty(muscleActivations)
            muscleActivationsParts{i} = muscleActivations(index : nextIndex, :);
        else
            muscleActivationsParts{i} = [];
        end
        index = nextIndex + 1;
    end
    
    parfor i = 1 : numWorkers
        if version >= 40501
            [inverseDynamicsMomentsParts{i}, angularMomentumParts{i}, metabolicCostParts{i}, ...
                massCenterVelocityParts{i}] = ...
                inverseDynamicsWithExtraCalcsMexWindows40501(timeParts{i}, ...
                jointAnglesParts{i}, jointVelocitiesParts{i}, jointAccelerationsParts{i}, ...
                coordinateLabels, appliedLoadsParts{i}, muscleActivationsParts{i}, ...
                computeAngularMomentum, computeMetabolicCost);
        else
            [inverseDynamicsMomentsParts{i}, angularMomentumParts{i}, metabolicCostParts{i}, ...
                massCenterVelocityParts{i}] = ...
                inverseDynamicsWithExtraCalcsMexWindows_1thread(timeParts{i}, ...
                jointAnglesParts{i}, jointVelocitiesParts{i}, jointAccelerationsParts{i}, ...
                coordinateLabels, appliedLoadsParts{i}, muscleActivationsParts{i}, ...
                computeAngularMomentum, computeMetabolicCost);
        end
    end

    inverseDynamicsMoments = inverseDynamicsMomentsParts{1};
    angularMomentum = angularMomentumParts{1};
    metabolicCost = metabolicCostParts{1};
    for part = 2 : numWorkers
        inverseDynamicsMoments = cat(1, inverseDynamicsMoments, inverseDynamicsMomentsParts{part});
        angularMomentum = cat(1, angularMomentum, angularMomentumParts{part});
        metabolicCost = cat(1, metabolicCost, metabolicCostParts{part});
    end
    massCenterVelocity = mean(cell2mat(massCenterVelocityParts));
else
    if nargout == 1
        inverseDynamicsMoments = inverseDynamicsMatlabParallel(time, ...
            jointAngles, jointVelocities, jointAccelerations, ...
            coordinateLabels, appliedLoads, modelName);
    else
        [inverseDynamicsMoments, angularMomentum] = ...
            inverseDynamicsMatlabParallel(time, ...
            jointAngles, jointVelocities, jointAccelerations, ...
            coordinateLabels, appliedLoads, modelName);
    end
    massCenterVelocity = [0; 0];
    metabolicCost = zeros(size(inverseDynamicsMoments, 1), 1);
end
end
