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
modelFile = getFieldByName(tree, 'input_model_file').Text;
if(inputDirectory)
    output.model = fullfile(inputDirectory, modelFile);
else
    output.model = fullfile(pwd, modelFile);
    inputDirectory = pwd;
end
directories.jointMoment = getFieldByName(tree, ...
    'joint_moment_directory').Text;
directories.muscleLength = getFieldByName(tree, ...
    'muscle_length_directory').Text;
directories.muscleVelocity = getFieldByName(tree, ...
    'muscle_velocity_directory').Text;
directories.muscleMomentArm = getFieldByName(tree, ...
    'muscle_moment_arm_directory').Text;
directories.emgData = getFieldByName(tree, 'emg_data_directory').Text;
inputs.tasks = getTasks(tree, inputDirectory, directories);
end

function params = getParams(tree)

end

