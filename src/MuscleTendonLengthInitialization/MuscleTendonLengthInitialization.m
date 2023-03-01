% This function is part of the NMSM Pipeline, see file for full license.
%
% muscle tendon length initialization personalizes optimal fiber length, slack tendon length, 
% and muscle specific tension (optional)
%
% (struct, struct) -> (struct)
% Runs the MuscleTendonLengthInitialization algorithm

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

function optimizedValues = MuscleTendonLengthInitialization(inputs)
primaryValues = prepareInitialValues(inputs);
lowerBounds = makeLowerBounds(inputs);
upperBounds = makeUpperBounds(inputs);
optimizerOptions = makeOptimizerOptions(struct());
[taskValues, taskLowerBounds, taskUpperBounds] = makeTaskValues( ...
    primaryValues, inputs, lowerBounds, upperBounds);
optimizedValues = computeMuscleTendonLengthInitializationOptimization(taskValues, ...
    taskLowerBounds, taskUpperBounds, inputs, optimizerOptions);
end

% extract initial version of optimized values from inputs/params
function values = prepareInitialValues(inputs)
numMuscles = length(inputs.muscleNames);
values{1} = ones(1, numMuscles); % optimal fiber length scale factor
values{2} = ones(1, numMuscles); % tendon slack length scale factor
values{3} = ones(1, inputs.numMuscleGroups + ...
    inputs.numMusclesIndividual); % maximum normalized fiber length
values{4} = ones(1, 1); % muscle specific tension
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
function lowerBounds = makeLowerBounds(inputs)
numMuscles = length(inputs.muscleNames);
lowerBounds{1} = repmat(0.5, 1, numMuscles); % optimal fiber length scale factor
lowerBounds{2} = repmat(0.5, 1, numMuscles); % tendon slack length scale factor
lowerBounds{3} = repmat(1, 1, inputs.numMuscleGroups + ...
    inputs.numMusclesIndividual); % maximum normalized fiber length
lowerBounds{4} = repmat(0.6, 1, 1); % muscle specific tension
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
function upperBounds = makeUpperBounds(inputs)
numMuscles = length(inputs.muscleNames);
upperBounds{1} = repmat(2, 1, numMuscles); % optimal fiber length scale factor
upperBounds{2} = repmat(2, 1, numMuscles); % tendon slack length scale factor
upperBounds{3} = repmat(1.2, 1, inputs.numMuscleGroups + ...
    inputs.numMusclesIndividual); % maximum normalized fiber length
upperBounds{4} = repmat(2.3, 1, 1); % muscle specific tension
end

% (struct) -> (struct)
% setup optimizer options struct to pass to fmincon
function output = makeOptimizerOptions(params)
output = optimset('UseParallel', true);
output.MaxIter = valueOrAlternate(params, 'maxIterations', 10000);
output.MaxFunEvals = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 100000000);
output.Display = 'iter';
end

% (struct, struct) -> (Array of number)
% prepare values to be optimized for the given task
function [taskValues, taskLowerBounds, taskUpperBounds] = ...
    makeTaskValues(primaryValues, taskInputs, ...
    lowerBounds, upperBounds)
taskValues = [];
taskLowerBounds = [];
taskUpperBounds = [];
for i = 1:length(primaryValues)-1
    taskValues = [taskValues primaryValues{i}];
    taskLowerBounds = [taskLowerBounds lowerBounds{i}];
    taskUpperBounds = [taskUpperBounds upperBounds{i}];
end
if taskInputs.maximumMuscleStressIsIncluded
    taskValues = [taskValues primaryValues{end}];
    taskLowerBounds = [taskLowerBounds lowerBounds{end}];
    taskUpperBounds = [taskUpperBounds upperBounds{end}];
end
end