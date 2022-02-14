% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Joint Model Personalization Settings XML file.
%
% (struct) -> (string, struct, struct)
% returns the input values for Joint Model Personalization

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

function [inputs, params, resultsDirectory] = ...
    parseMuscleTendonPersonalizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
end

function inputs = getInputs(tree)
inputDirectory = getFieldByName(tree, 'input_directory').Text;
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
if(inputDirectory)
    inputs.model = Model(fullfile(inputDirectory, modelFile));
else
    inputs.model = Model(fullfile(pwd, modelFile));
    inputDirectory = pwd;
end
inputs.jointMoment = parseMtpStandard(fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, 'joint_moment_directory').Text));
inputs.muscleTendonLength = ...
    parseMuscleTendonLengths(fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, 'muscle_length_directory').Text));
inputs.muscleTendonVelocity = parseMtpStandard(fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, 'muscle_velocity_directory').Text));
inputs.muscleTendonMomentArm = parseMomentArms(fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, 'muscle_moment_arm_directory').Text), ...
    inputs.model);
inputs.emgData = parseMtpStandard(fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, 'emg_data_directory').Text));
inputs.tasks = getTasks(tree);
end

% (struct, string, struct) -> (struct)
function output = getTasks(tree)
tasks = getFieldByNameOrError(tree, 'MuscleTendonPersonalizationTaskList');
counter = 1;
for i=1:length(tasks.MuscleTendonPersonalizationTask)
    if(length(tasks.MuscleTendonPersonalizationTask) == 1)
        task = tasks.MuscleTendonPersonalizationTask;
    else
        task = tasks.MuscleTendonPersonalizationTask{i};
    end
    if(task.is_enabled.Text == 'true')
        output{counter} = getTask(task);
        counter = counter + 1;
    end
end
end

% (integer, struct, string, struct) -> (struct)
function output = getTask(tree)
items = ["optimize_electromechanical_delays", ...
    "optimize_activation_time_constants", ...
    "optimize_activation_nonlinearity_constants", ...
    "optimize_emg_scale_factors", "optimize_optimal_muscle_lengths", ...
    "optimize_tendon_slack_lengths"];
output = zeros(1,length(items));
for i=1:length(items)
    tree.(items(i)).Text
    output(i) = strcmp(tree.(items(i)).Text, 'true');
end
end

% (struct) -> (struct)
function params = getParams(tree)
params = struct();
maxIterations = getFieldByName(tree, 'max_iterations');
if(isstruct(maxIterations))
    params.maxIterations = maxIterations.Text;
end
maxFunctionEvaluations = getFieldByName(tree, 'max_function_evaluations');
if(isstruct(maxFunctionEvaluations))
    params.maxFunctionEvaluations = maxFunctionEvaluations.Text;
end
end

