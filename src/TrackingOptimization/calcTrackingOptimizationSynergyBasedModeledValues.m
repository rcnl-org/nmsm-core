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

function phaseout = calcTrackingOptimizationSynergyBasedModeledValues(...
    values, params, phaseout)

jointAngles = getMuscleActuatedDOFs(values, params);
[params.muscleTendonLength, params.momentArms] = calcSurrogateModel( ...
    params, jointAngles);
params.muscleTendonVelocity = calcMuscleTendonVelocities(values.time, ...
    params.muscleTendonLength, params.smoothingParam);
[phaseout.normalizedFiberLength, phaseout.normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(params, ...
    ones(1, params.numMuscles), ones(1, params.numMuscles));
phaseout.muscleActivations = calcMuscleActivationFromSynergies(values, params);
phaseout.muscleJointMoments = calcMuscleJointMoments(params, ...
    phaseout.muscleActivations, phaseout.normalizedFiberLength, ...
    phaseout.normalizedFiberVelocity);
phaseout.muscleJointMoments(:, all(~phaseout.muscleJointMoments, 1)) = [];
end

function muscleActivations = calcMuscleActivationFromSynergies(values, params)

rightMuscleActivations = values.controlNeuralCommandsRight * ...
    values.synergyWeights(1 : params.numRightSynergies, :);
leftMuscleActivations = values.controlNeuralCommandsLeft * ...
    values.synergyWeights(params.numRightSynergies + 1 : end, :);
muscleActivations = [rightMuscleActivations leftMuscleActivations];
end
function jointAngles = getMuscleActuatedDOFs(values, params)

for i = 1:params.numMuscles
    index = 1;
    for j = 1:size(params.dofsActuated, 1)
        if params.dofsActuated(j, i) > params.epsilon
            jointAngles{i}(:, index) = values.statePositions(:, j);
            index = index + 1;
        end
    end
end
end
function muscleTendonVelocities = calcMuscleTendonVelocities(time, ...
    muscleTendonLength, smoothingParam)

for i = 1 : size(muscleTendonLength, 2)
    muscleTendonVelocities(:, i) = calcDerivative(time, ...
        muscleTendonLength(:, i), smoothingParam);
end
end