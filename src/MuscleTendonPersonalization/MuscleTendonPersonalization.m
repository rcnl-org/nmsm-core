% This function is part of the NMSM Pipeline, see file for full license.
%
% Muscle Tendon Personalization uses movement and EMG data to personalize
% the muscle characteristics of the patient.
%
% inputs:
%   - model (Model)
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

function primaryValues = MuscleTendonPersonalization(inputs, params)
verifyInputs(inputs); % (struct) -> (None)
verifyParams(params); % (struct) -> (None)
primaryValues = prepareInitialValues(inputs, params);
lowerBounds = makeLowerBounds(inputs, params);
upperBounds = makeUpperBounds(inputs, params);
optimizerOptions = makeOptimizerOptions(params);
for i=1:length(inputs.tasks)
    taskValues = makeTaskValues(primaryValues, inputs.tasks{i}, params);
    taskParams = makeTaskParams(inputs.tasks{i}, params);
    optimizedValues = computeMuscleTendonRoundOptimization(taskValues, ...
        lowerBounds, upperBounds, taskParams, optimizerOptions);
    primaryValues = updateDesignVariables(primaryValues, ...
        optimizedValues, taskParams);
end
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
% extract initial version of optimized values from inputs/params
function values = prepareInitialValues(inputs, params)
numMuscles = getNumEnabledMuscles(inputs.model);
values = zeros(6, numMuscles);
values(1,:) = 0.5; % electromechanical delay
values(2,:) = 1.5; % activation time
values(3,:) = 0.05; % activation nonlinearity
values(4,:) = 0.5; % EMG scale factors
values(5,:) = 1; % lmo scale factor
values(6,:) = 1; % lts scale factor
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
function lowerBounds = makeLowerBounds(inputs, params)
if isfield(params, 'lowerBounds')
    lowerBounds = params.lowerBounds;
else
    numMuscles = getNumEnabledMuscles(inputs.model);
    lowerBounds = zeros(6, numMuscles);
    lowerBounds(1,:) = 0.0; % electromechanical delay
    lowerBounds(2,:) = 0.75; % activation time
    lowerBounds(3,:) = 0.0; % activation nonlinearity
    lowerBounds(4,:) = 0.05; % EMG scale factors
    lowerBounds(5,:) = 0.6; % lmo scale factor
    lowerBounds(6,:) = 0.6; % lts scale factor
end
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
function upperBounds = makeUpperBounds(inputs, params)
if isfield(params, 'upperBounds')
    upperBounds = params.upperBounds;
else
    numMuscles = getNumEnabledMuscles(inputs.model);
    upperBounds = zeros(6, numMuscles);
    upperBounds(1,:) = 1.25; % electromechanical delay
    upperBounds(2,:) = 3.5; % activation time
    upperBounds(3,:) = 0.35; % activation nonlinearity
    upperBounds(4,:) = 1; % EMG scale factors
    upperBounds(5,:) = 1.4; % lmo scale factor
    upperBounds(6,:) = 1.4; % lts scale factor
end
end

% (struct) -> (struct)
% setup optimizer options struct to pass to fmincon
function output = makeOptimizerOptions(params)
output = optimoptions('fmincon', 'UseParallel', true);
output.MaxIterations = valueOrAlternate(params, 'maxIterations', 2000);
output.MaxFunctionEvaluations = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 100000000);
output.Algorithm = valueOrAlternate(params, 'algorithm', 'sqp');
output.ScaleProblem = valueOrAlternate(params, 'scaleProblem', ...
    'obj-and-constr');
end

% (struct, struct) -> (Array of number)
% prepare values to be optimized for the given task
function taskValues = makeTaskValues(primaryValues, taskInputs, params)
taskValues = [];
for i=1:length(taskInputs.isIncluded)
   if(taskInputs.isIncluded(i))
       taskValues = [taskValues primaryValues(i,:)];
   end
end
end

% (struct, struct) -> (struct)
% prepare optimizer parameters for the given task
function taskParams = makeTaskParams(taskInputs, params)

end