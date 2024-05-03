% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates muscle tendon lengths and velocities along with
% moment arms from a surrogate model. These quantities are used to
% calculate normalized fiber lengths and velocities. Muscle activations are
% calculated from muscles synergies and all of these quantities are used to
% calculate the muscle produced joint moments.
%
% (struct, struct, struct) -> (struct)
% Returns normalized fiber lengths and velocities, muscle activations, and
% muscle joint moments

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function modeledValues = calcSynergyBasedModeledValues(values, inputs)
if strcmp(inputs.controllerType, 'synergy')
    [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, inputs);
    [inputs.muscleTendonLength, inputs.momentArms, ...
        inputs.muscleTendonVelocity] = calcSurrogateModel(inputs, ...
        jointAngles, jointVelocities);
    inputs.muscleTendonLength = permute(inputs.muscleTendonLength, [3 2 1]);
    inputs.muscleTendonVelocity = permute(inputs.muscleTendonVelocity, [3 2 1]);
    inputs.momentArms = permute(inputs.momentArms, [4 2 3 1]);
    [modeledValues.normalizedFiberLength, modeledValues.normalizedFiberVelocity] = ...
        calcNormalizedMuscleFiberLengthsAndVelocities(inputs, ...
        ones(1, inputs.numMuscles), ones(1, inputs.numMuscles));
    modeledValues.muscleActivations = calcMuscleActivationFromSynergies(values);
    muscleJointMoments = calcMuscleJointMoments(inputs, ...
        modeledValues.muscleActivations, modeledValues.normalizedFiberLength, ...
        modeledValues.normalizedFiberVelocity);
    modeledValues.muscleJointMoments = permute(muscleJointMoments, [3 2 1]);
    modeledValues.muscleJointMoments = modeledValues.muscleJointMoments(:, ...
        inputs.surrogateModelIndex);
    modeledValues.muscleActivations = permute(modeledValues.muscleActivations, [3 2 1]);
else
    modeledValues.muscleActivations = [];
end
end

function muscleActivations = calcMuscleActivationFromSynergies(values)
muscleActivations = values.controlSynergyActivations * values.synergyWeights;
muscleActivations = permute(muscleActivations, [3 2 1]);
end

function [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, inputs)
for i = 1 : inputs.numMuscles
    counter = 1;
    for j = 1:length(inputs.coordinateNames)
        for k = 1:length(inputs.surrogateModelLabels{i})
            if strcmp(inputs.coordinateNames(j), inputs.surrogateModelLabels{i}{k})
                jointAngles{i}(:, counter) = values.positions(:, j);
                jointVelocities{i}(:, counter) = values.velocities(:, j);
                counter = counter + 1;
            end
        end
    end
end
end