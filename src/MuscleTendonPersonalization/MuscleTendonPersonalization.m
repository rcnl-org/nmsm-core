% This function is part of the NMSM Pipeline, see file for full license.
%
% Muscle Tendon Personalization uses movement and EMG data to personalize
% the muscle characteristics of the patient.
%
% inputs:
%   - tasks (cell array)
%       - isIncluded (array of boolean)
%   - model (string)
%   - jointMoment (3D array)
%   - muscleTendonLength (3D array)
%   - muscleTendonVelocity (3D array)
%   - muscleTendonMomentArm (4D array)
%   - emgData (3D array)
%   - experimentalData (struct) - see costFunction
%
% (struct, struct) -> (struct)
% Runs the Muscle Tendon Personalization algorithm

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function results = MuscleTendonPersonalization(inputs, ...
    params)
inputs.primaryValues = prepareInitialValues(inputs, params);
inputs = finalizeInputs(inputs, inputs.primaryValues, params);
lowerBounds = makeLowerBounds(inputs, params);
upperBounds = makeUpperBounds(inputs, params);
optimizerOptions = makeOptimizerOptions(params);
for i=1:length(inputs.tasks)
    [taskValues, taskLowerBounds, taskUpperBounds] = makeTaskValues( ...
        inputs.primaryValues, inputs.tasks{i}, lowerBounds, upperBounds);
    taskParams = makeTaskParams(params);
    if isfield(inputs, "synergyExtrapolation")
        taskParams.costTerms = ...
            [inputs.tasks{i}.costTerms,  inputs.synergyExtrapolation.costTerms];
        taskParams.maxNormalizedMuscleFiberLength = ...
            inputs.tasks{i}.maxNormalizedMuscleFiberLength;
        taskParams.minNormalizedMuscleFiberLength = ...
            inputs.tasks{i}.minNormalizedMuscleFiberLength;
        [A, b] = getLinearInequalityConstraints(inputs.synergyExtrapolation, ...
            sum(inputs.tasks{i}.isIncluded(1:6)) * ...
            length(inputs.muscleNames), inputs.extrapolationCommands, ...
            permute(inputs.emgData, [3 1 2]));
        optimizedValues = computeMuscleTendonRoundOptimization(taskValues, ...
            inputs.primaryValues, inputs.tasks{i}.isIncluded, taskLowerBounds, ...
            taskUpperBounds, inputs, taskParams, optimizerOptions, A, b);
    else
        taskParams.costTerms = inputs.tasks{i}.costTerms;
        optimizedValues = computeMuscleTendonRoundOptimization(taskValues, ...
            inputs.primaryValues, inputs.tasks{i}.isIncluded, taskLowerBounds, ...
            taskUpperBounds, inputs, taskParams, optimizerOptions, [], []);
    end
    inputs.primaryValues = updateDesignVariables(inputs.primaryValues, ...
        optimizedValues, inputs.tasks{i}.isIncluded);
    inputs = updateScaleFactors(inputs);
end
results = inputs;
end

function [inputs] = updateScaleFactors(inputs)
    inputs.optimalFiberLength = inputs.optimalFiberLength .* ...
        inputs.primaryValues{5};
    inputs.tendonSlackLength = inputs.tendonSlackLength .* ...
        inputs.primaryValues{6};
    inputs.primaryValues{5} = ones(size(inputs.primaryValues{5}));
    inputs.primaryValues{6} = ones(size(inputs.primaryValues{6}));
end

% (struct) -> (None)
% throws an error if any of the inputs are invalid
function verifyInputs(inputs)
try verifyModelArg(inputs.model); %check model args
catch; throw(MException('','inputs.model cannot instantiate a model')); end
try verifyMuscleTendonPersonalizationData(inputs);
catch; throw(MException('','data is not of matching sizes')); end
for i=1:length(inputs.tasks)
    try verifyNumeric(inputs.tasks{i}.isIncluded);
    catch; throw(MException('',strcat('invalid isIncluded boolean', ...
            'array for task ', num2str(i))));
    end
end
end

% (struct) -> (None)
% throws an error if the parameter is included but is not of valid type
function verifyParams(params)
if(isfield(params, 'maxIterations'))
    verifyParam(params, 'maxIterations', @verifyNumeric, ...
        'param maxFunctionEvaluations is not a number');
end
if(isfield(params, 'maxFunctionEvaluations'))
    verifyParam(params, 'maxFunctionEvaluations', @verifyNumeric, ...
        'param maxFunctionEvaluations is not a number');
end
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
% extract initial version of optimized values from inputs/params
function values = prepareInitialValues(inputs, params)
numMuscles = length(inputs.muscleNames);
values{1} = repmat(0.5, 1, numMuscles); % electromechanical delay
values{2} = repmat(1.5, 1, numMuscles); % activation time
values{3} = repmat(0.05, 1, numMuscles); % activation nonlinearity
values{4} = repmat(0.5, 1, numMuscles); % EMG scale factors
values{5} = repmat(1, 1, numMuscles); % optimal fiber length scale factor
values{6} = repmat(1, 1, numMuscles); % tendon slack length scale factor
if isfield(inputs, "synergyExtrapolation")
    values{7} = repmat(0, 1, inputs.numberOfExtrapolationWeights + ...
        inputs.numberOfResidualWeights); % synergy commands
end
end

function inputs = finalizeInputs(inputs, primaryValues, params)
values = makeMtpValuesAsStruct(struct(), primaryValues, zeros(1, 7), inputs);
modeledValues = calcMtpModeledValues(values, inputs, params);
inputs = mergeStructs(inputs, modeledValues);
inputs = rmfield(inputs, "model");
if ~isfield(inputs, "synergyExtrapolation")
    for i = 1:length(inputs.tasks)
        inputs.tasks{i}.isIncluded(7) = 0;
    end
end
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
function lowerBounds = makeLowerBounds(inputs, params)
if isfield(params, 'lowerBounds')
    lowerBounds = params.lowerBounds;
else
    numMuscles = length(inputs.muscleNames);
    lowerBounds{1} = repmat(0.0, 1, numMuscles); % electromechanical delay
    lowerBounds{2} = repmat(0.75, 1, numMuscles); % activation time
    lowerBounds{3} = repmat(0.0, 1, numMuscles); % activation nonlinearity
    lowerBounds{4} = repmat(0.05, 1, numMuscles); % EMG scale factors
    lowerBounds{5} = repmat(0.6, 1, numMuscles); % optimal fiber length scale factor
    lowerBounds{6} = repmat(0.6, 1, numMuscles); % tendon slack length scale factor
    if isfield(inputs, "synergyExtrapolation")
        lowerBounds{7} = repmat(-100, 1, inputs.numberOfExtrapolationWeights + ...
            inputs.numberOfResidualWeights); % synergy commands
    end
end
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
function upperBounds = makeUpperBounds(inputs, params)
if isfield(params, 'upperBounds')
    upperBounds = params.upperBounds;
else
    numMuscles = length(inputs.muscleNames);
    upperBounds{1} = repmat(1.25, 1, numMuscles); % electromechanical delay
    upperBounds{2} = repmat(3.5, 1, numMuscles); % activation time
    upperBounds{3} = repmat(0.35, 1, numMuscles); % activation nonlinearity
    upperBounds{4} = repmat(1, 1, numMuscles); % EMG scale factors
    upperBounds{5} = repmat(1.4, 1, numMuscles); % optimal fiber length scale factor
    upperBounds{6} = repmat(1.4, 1, numMuscles); % tendon slack length scale factor
    if isfield(inputs, "synergyExtrapolation")
        upperBounds{7} = repmat(100, 1, inputs.numberOfExtrapolationWeights + ...
            inputs.numberOfResidualWeights); % synergy commands
    end
end
end

% (struct) -> (struct)
% setup optimizer options struct to pass to fmincon
function output = makeOptimizerOptions(params)
output = optimset('UseParallel', true);
output.MaxIter = valueOrAlternate(params, 'maxIterations', 10000);
output.MaxFunEvals = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 100000000);
output.TolX = valueOrAlternate(params, ...
    'stepTolerance', 1e-6);
output.Algorithm = valueOrAlternate(params, 'algorithm', 'sqp');
output.ScaleProblem = valueOrAlternate(params, 'scaleProblem', ...
    'obj-and-constr');
output.Display = 'iter';
output.Hessian = 'lbfgs';
output.GradObj = 'off';
output.DiffMaxChange = 10;
output.DiffMinChange = 1e-5;
end

% (struct, struct) -> (Array of number)
% prepare values to be optimized for the given task
function [taskValues, taskLowerBounds, taskUpperBounds] = ...
    makeTaskValues(primaryValues, taskInputs, lowerBounds, upperBounds)
taskValues = [];
taskLowerBounds = [];
taskUpperBounds = [];
for i = 1:length(taskInputs.isIncluded)
    if(taskInputs.isIncluded(i))
        taskValues = [taskValues primaryValues{i}];
        taskLowerBounds = [taskLowerBounds lowerBounds{i}];
        taskUpperBounds = [taskUpperBounds upperBounds{i}];
    end
end
end

% (struct, struct) -> (struct)
% prepare optimizer parameters for the given task
function taskParams = makeTaskParams(params)
taskParams = params;
if(~isfield(params, 'maxIterations'))
    taskParams.maxIterations = 2e3;
end
if(isfield(params, 'maxFunctionEvaluations'))
    taskParams.maxFunctionEvaluations = 1e8;
end
end