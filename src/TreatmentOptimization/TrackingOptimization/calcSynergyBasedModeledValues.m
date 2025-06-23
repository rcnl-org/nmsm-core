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
if any(inputs.controllerTypes(2:3))
    [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, inputs);
    [muscleTendonLength, momentArms, muscleTendonVelocity] = ...
        calcSurrogateModel(inputs, jointAngles, jointVelocities);
    [modeledValues.normalizedFiberLength, ...
        modeledValues.normalizedFiberVelocity] = ...
        calcNormalizedFiberQuantities(inputs, muscleTendonLength, ...
        muscleTendonVelocity);
    if inputs.controllerTypes(2)
        synergyMuscleActivations = ...
            calcMuscleActivationFromSynergies(values);
    else
        synergyMuscleActivations = [];
    end
    modeledValues.muscleActivations = combineMuscleActivations(values, ...
        inputs, synergyMuscleActivations);
    if inputs.useActivationSaturation
        modeledValues.muscleActivations = ...
            applyActivationSaturation(modeledValues.muscleActivations, ...
            inputs.activationSaturationSharpness);
    end
    if strcmp(inputs.solverType, 'gpops')
        modeledValues.muscleJointMoments = ...
            calcTreatmentOptimizationMuscleJointMoments(inputs, ...
            modeledValues, momentArms);
    else
        modeledValues.muscleJointMoments = ...
            calcCasadiTreatmentOptimizationMuscleJointMoments(inputs, ...
            modeledValues, momentArms);
    end

    if sum(valueOrAlternate(inputs, 'calculateMetabolicCost', false))
        modeledValues.metabolicCost = calcBhargavaMetabolicCost( ...
            inputs.mass, modeledValues.muscleActivations, ...
            modeledValues.normalizedFiberLength, ...
            modeledValues.normalizedFiberVelocity, ...
            inputs.maxIsometricForce, inputs.optimalFiberLength);
    end
else
    modeledValues.normalizedFiberLength = [];
    modeledValues.normalizedFiberVelocity = [];
    modeledValues.muscleActivations = [];
    modeledValues.muscleJointMoments = [];
    modeledValues.metabolicCost = [];
end
end

function [normalizedFiberLengths, normalizedFiberVelocities] = ...
    calcNormalizedFiberQuantities(inputs, muscleTendonLength, ...
    muscleTendonVelocity)
if isa(muscleTendonLength, 'casadi.MX')
    tendonSlackLength = repmat(inputs.tendonSlackLength, ...
        size(muscleTendonLength, 1), 1);
    lengthDenom = repmat(inputs.optimalFiberLength .* ...
        cos(inputs.pennationAngle), size(muscleTendonLength, 1), 1);
    velocityDenom = repmat(inputs.vMaxFactor .* ...
        inputs.optimalFiberLength .* cos(inputs.pennationAngle), ...
        size(muscleTendonLength, 1), 1);
else
    tendonSlackLength = inputs.tendonSlackLength;
    lengthDenom = inputs.optimalFiberLength .* cos(inputs.pennationAngle);
    velocityDenom = inputs.vMaxFactor .* inputs.optimalFiberLength .* ...
        cos(inputs.pennationAngle);
end
normalizedFiberLengths = (muscleTendonLength - ...
    tendonSlackLength) ./ lengthDenom;
normalizedFiberVelocities = muscleTendonVelocity ./ velocityDenom;
end

function muscleActivations = calcMuscleActivationFromSynergies(values)
muscleActivations = values.controlSynergyActivations * values.synergyWeights;
end

function [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, inputs)
persistent indexMatrix, persistent coordinatesPerMuscle;
if isempty(indexMatrix)
    indexMatrix = zeros(0, 3);
    coordinatesPerMuscle = zeros(1, inputs.numMuscles);
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
        coordinatesPerMuscle(i) = counter - 1;
    end
end
jointAngles = cell(1, inputs.numMuscles);
jointVelocities = jointAngles;
if isa(values.positions, 'casadi.MX')
    for i = 1 : inputs.numMuscles
        jointAngles{i} = casadi.MX.zeros(size(values.positions, 1), ...
            coordinatesPerMuscle(i));
        jointVelocities{i} = casadi.MX.zeros(size(values.positions, 1), ...
            coordinatesPerMuscle(i));
    end
end
for i = 1 : size(indexMatrix, 1)
    jointAngles{indexMatrix(i, 1)}(:, indexMatrix(i, 2)) = ...
        values.positions(:, indexMatrix(i, 3));
    jointVelocities{indexMatrix(i, 1)}(:, indexMatrix(i, 2)) = ...
        values.velocities(:, indexMatrix(i, 3));
end
end

function muscleActivations = combineMuscleActivations(values, ...
        inputs, synergyMuscleActivations)
if isempty(synergyMuscleActivations)
    muscleActivations = values.controlMuscleActivations;
    return
end
if ~isfield(values, 'controlMuscleActivations')
    muscleActivations = synergyMuscleActivations;
    return
end
persistent synergyIndices, persistent individualIndices;
if isempty(individualIndices)
    [~, ~, individualIndices] = intersect( ...
        inputs.individualMuscleNames, inputs.muscleNames, 'stable');
end
if isempty(synergyIndices)
    [~, ~, synergyIndices] = intersect( ...
        inputs.synergyMuscleNames, inputs.muscleNames, 'stable');
end
if isa(synergyMuscleActivations, 'casadi.MX')
    muscleActivations = casadi.MX.zeros(length(values.time), ...
        inputs.numMuscles);
else
    muscleActivations = zeros(length(values.time), inputs.numMuscles);
end
muscleActivations(:, individualIndices) = values.controlMuscleActivations;
muscleActivations(:, synergyIndices) = synergyMuscleActivations;
end
