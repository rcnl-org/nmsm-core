% This function is part of the NMSM Pipeline, see file for full license.
%
% This function runs ipopt for Neural Control Personalization, preparing
% any necessary options and constraints for the optimizer. 
%
% (Array of double, struct, struct) -> (Array of double)
% Runs ipopt optimization for Neural Control Personalization. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [finalValues, inputs, params] = ...
    computeNeuralControlOptimizationWithCasadi( ...
    initialValues, inputs, params)
optimizer = casadi.Opti();
params.numMeshes = 25;
params.numCollocationPerMesh = 4;

% Create new time vector
inputs = calcCollocationPointTimes(inputs, params);

% Preindex optimizer variable to matrix conversions TODO
totalNumWeights = 0;
inputs.weightVectorLengths = [];
inputs.weightMatrixMap = false(inputs.numMuscles, inputs.numSynergies);
muscleIndex = 0;
weightIndex = 0;
for i = 1 : length(inputs.synergyGroups)
    totalNumWeights = totalNumWeights + ...
        inputs.synergyGroups{i}.numSynergies * ...
        length(inputs.synergyGroups{i}.muscleNames);
    inputs.weightVectorLengths(end + 1 : ...
        end + inputs.synergyGroups{i}.numSynergies) = ...
        length(inputs.synergyGroups{i}.muscleNames);
    inputs.weightMatrixMap(muscleIndex + 1 : ...
        muscleIndex + length(inputs.synergyGroups{i}.muscleNames), ...
        weightIndex + 1 : ...
        weightIndex + inputs.synergyGroups{i}.numSynergies) = true;
    muscleIndex = muscleIndex + ...
        length(inputs.synergyGroups{i}.muscleNames);
    weightIndex = weightIndex + inputs.synergyGroups{i}.numSynergies;
end
inputs.weightMatrixDimensions = size(inputs.weightMatrixMap);
inputs.weightMatrixMap = find(inputs.weightMatrixMap);

% Create variables
weights = optimizer.variable(totalNumWeights);
commandsState = optimizer.variable( ...
    inputs.numTrials * inputs.numSynergies, ...
    params.numMeshes * params.numCollocationPerMesh + 1);
commandsControl = optimizer.variable( ...
    inputs.numTrials * inputs.numSynergies, ...
    params.numMeshes * params.numCollocationPerMesh + 1);

% Initialize variables
optimizer.set_initial(weights, 0.01 * ones(size(weights)));
optimizer.set_initial(commandsState, 1 * ones(size(commandsState)));
optimizer.set_initial(commandsControl, 0 * ones(size(commandsControl)));

% Load reference data into symbolic function
[inputs.normalizedFiberLengths, inputs.normalizedFiberVelocities] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities( ...
    inputs, inputs.optimalFiberLengthScaleFactors, ...
    inputs.tendonSlackLengthScaleFactors);
inputs = makeLoadedData2D(inputs);
inputs = resplineLoadedData(inputs);
evaluateNeuralControlPersonalizationSymbolicFunction(inputs, params);

% Evaluate symbolic function
[dynamics, inequalityConstraints, equalityConstraints, objective] = ...
    evaluateNeuralControlPersonalizationSymbolicFunction(weights, ...
    commandsState, commandsControl);

% Apply variable bounds
optimizer.subject_to(weights(:) > 0);
optimizer.subject_to(commandsState(:) > 0);

% Apply dynamic constraint
optimizer.subject_to(dynamics(:) == 0);

% Apply constraints
optimizer.subject_to(inequalityConstraints(:) < 0);
optimizer.subject_to(equalityConstraints(:) == 0);

% Minimize objective
optimizer.minimize(objective);

% Apply solver settings
casadiSettings.detect_simple_bounds = true;
casadiSettings.ipopt.tol = 1e-6;
casadiSettings.ipopt.constr_viol_tol = 1e-4;
optimizer.solver('ipopt', casadiSettings);

% Solve problem, catching solver failures if needed
try
    casadiSolution = optimizer.solve();
catch
    warning(['Solver failed with status ' ...
        optimizer.debug.stats.return_status ...
        '. Debug results will be saved.']);
    casadiSolution = optimizer.debug;
end

% Unpack solution values
finalValues.weights = casadiSolution.value(weights);
finalValues.commandsState = casadiSolution.value(commandsState);
finalValues.commandsControl = casadiSolution.value(commandsControl);
end

% Respline data to use collocation time
function inputs = resplineLoadedData(inputs)
inputs.inverseDynamicsMoments = resplineDataToNewTime( ...
    inputs.inverseDynamicsMoments, inputs.time, inputs.collocationTime);
inputs.muscleTendonLength = resplineDataToNewTime( ...
    inputs.muscleTendonLength, inputs.time, inputs.collocationTime);
inputs.muscleTendonVelocity = resplineDataToNewTime( ...
    inputs.muscleTendonVelocity, inputs.time, inputs.collocationTime);
inputs.mtpActivations = resplineDataToNewTime( ...
    inputs.mtpActivations, inputs.time, inputs.collocationTime);
inputs.momentArms = resplineDataToNewTime( ...
    inputs.momentArms, inputs.time, inputs.collocationTime);
inputs.normalizedFiberLengths = resplineDataToNewTime( ...
    inputs.mtpActivations, inputs.time, inputs.collocationTime);
inputs.normalizedFiberVelocities = resplineDataToNewTime( ...
    inputs.mtpActivations, inputs.time, inputs.collocationTime);
end

% Matrix math in CasADi does not work above 2D, so matrices interacting
% with MX variables must be reshaped.
function inputs = makeLoadedData2D(inputs)
inputs.inverseDynamicsMoments = reshape(permute( ...
    inputs.inverseDynamicsMoments, [2 1 3]), ...
    size(inputs.inverseDynamicsMoments, 1) * ...
    size(inputs.inverseDynamicsMoments, 2), []);
inputs.muscleTendonLength = reshape(permute( ...
    inputs.muscleTendonLength, [2 1 3]), ...
    size(inputs.muscleTendonLength, 1) * ...
    size(inputs.muscleTendonLength, 2), []);
inputs.muscleTendonVelocity = reshape(permute( ...
    inputs.muscleTendonVelocity, [2 1 3]), ...
    size(inputs.muscleTendonVelocity, 1) * ...
    size(inputs.muscleTendonVelocity, 2), []);
inputs.mtpActivations = reshape(permute( ...
    inputs.mtpActivations, [2 1 3]), ...
    size(inputs.mtpActivations, 1) * ...
    size(inputs.mtpActivations, 2), []);
inputs.momentArms = reshape(permute( ...
    inputs.momentArms, [3 2 1 4]), ...
    size(inputs.momentArms, 1) * ...
    size(inputs.momentArms, 2) * ...
    size(inputs.momentArms, 3), []);
inputs.normalizedFiberLengths = reshape(permute( ...
    inputs.normalizedFiberLengths, [2 1 3]), ...
    size(inputs.mtpActivations, 1) * ...
    size(inputs.mtpActivations, 2), []);
inputs.normalizedFiberVelocities = reshape(permute( ...
    inputs.normalizedFiberVelocities, [2 1 3]), ...
    size(inputs.mtpActivations, 1) * ...
    size(inputs.mtpActivations, 2), []);
end

% Find left-handed Radau collocation points
function inputs = calcCollocationPointTimes(inputs, params)
rootTime = casadi.collocation_points( ...
    params.numCollocationPerMesh, 'radau');
rootTime = rootTime(1:end-1);
meshTime = linspace(inputs.time(1), ...
    inputs.time(end), ...
    params.numMeshes + 1);
meshDuration = mean(diff(meshTime));
collocationTime = [];
for i = 1 : length(meshTime) - 1
    collocationTime(end+1:end+1+length(rootTime)) ...
        = [meshTime(i), meshTime(i) + meshDuration * rootTime];
end
% inputs.collocationTimeOriginal = collocationTime';
% inputs.collocationTimeOriginalWithEnd = inputs.collocationTimeOriginal;
% inputs.collocationTimeOriginalWithEnd(end + 1) = ...
%     inputs.time(end);
inputs.collocationTime = collocationTime;
inputs.collocationTime(end + 1) = inputs.time(end);
end

