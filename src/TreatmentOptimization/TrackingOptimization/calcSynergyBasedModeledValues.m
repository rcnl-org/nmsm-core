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
    [muscleTendonLength, momentArms, muscleTendonVelocity] = ...
        calcSurrogateModel(inputs, jointAngles, jointVelocities);
    [modeledValues.normalizedFiberLength, ...
        modeledValues.normalizedFiberVelocity] = ...
        calcNormalizedFiberQuantities(inputs, muscleTendonLength, ...
        muscleTendonVelocity);
    modeledValues.muscleActivations = calcMuscleActivationFromSynergies(values);
    modeledValues.muscleJointMoments = ...
        calcTreatmentOptimizationMuscleJointMoments(inputs, ...
        modeledValues, momentArms);
else
    modeledValues.muscleActivations = [];
end
end

function [normalizedFiberLengths, normalizedFiberVelocities] = ...
    calcNormalizedFiberQuantities(inputs, muscleTendonLength, ...
    muscleTendonVelocity)
normalizedFiberLengths = (muscleTendonLength - ...
    inputs.tendonSlackLength) ./ (inputs.optimalFiberLength .* ...
    cos(inputs.pennationAngle));
normalizedFiberVelocities = muscleTendonVelocity ./ (inputs.vMaxFactor ...
    .* inputs.optimalFiberLength .* cos(inputs.pennationAngle));
end

function muscleActivations = calcMuscleActivationFromSynergies(values)
muscleActivations = values.controlSynergyActivations * values.synergyWeights;
end

function [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, inputs)
persistent indexMatrix;
if isempty(indexMatrix)
    indexMatrix = zeros(0, 3);
    for i = 1 : inputs.numMuscles
        counter = 1;
        for j = 1:length(inputs.coordinateNames)
            for k = 1:length(inputs.surrogateModelLabels{i})
                if strcmp(inputs.coordinateNamesStrings(j), inputs.surrogateModelLabels{i}(k))
                    indexMatrix(end+1, :) = [i, counter, j];
                    counter = counter + 1;
                end
            end
        end
    end
end
jointAngles = cell(1, inputs.numMuscles);
jointVelocities = jointAngles;
for i = 1 : size(indexMatrix, 1)
    jointAngles{indexMatrix(i, 1)}(:, indexMatrix(i, 2)) = ...
        values.positions(:, indexMatrix(i, 3));
    jointVelocities{indexMatrix(i, 1)}(:, indexMatrix(i, 2)) = ...
        values.velocities(:, indexMatrix(i, 3));
end
end
