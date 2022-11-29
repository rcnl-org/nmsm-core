% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (string, string, string, string) -> (None)
% Makes new EMG data files with columns matching the file given

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

function [inputs, params] = parseMtpPreprocessing(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
end

function inputs = getInputs(tree)
inputs.resultsDir = getFieldByName(tree, "results_directory").Text;
if(isempty(inputs.resultsDir))
    inputs.resultsDir = pwd;
end
inputDirectory = getFieldByName(tree, "input_directory").Text;
if(isempty(inputDirectory))
    inputDirectory = pwd;
end
inputs.model = fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, "input_model_file").Text);
inputs.ikResultsFileName = fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, "inverse_kinematics_file").Text);
inputs.idResultsFileName = fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, "inverse_dynamics_file").Text);
inputs.emgFileName = fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, "emg_file").Text);
inputs.maResultsDir = fullfile(inputDirectory, ...
    getFieldByNameOrError(tree, "muscle_analysis_directory").Text);
inputs.coordinates = getCoordinateList(getFieldByNameOrError(tree, ...
    "MTPCoordinateList").Text);
inputs.muscleTendonVelocityCutoffFrequency = getFieldByNameOrError( ...
    tree, "muscle_tendon_velocity_cutoff_frequency").Text;
inputs.timeGroups = getTimeGroups(tree);
inputs.prefix = getFieldByNameOrError(tree, "MTPTrialPrefix").Text;
end

function coordinateList = getCoordinateList(spaceSeparatedList)
coordinateList = [];
if(~isempty(spaceSeparatedList))
    coordinateList = strsplit(spaceSeparatedList, ' ');
end
end

function timeGroups = getTimeGroups(tree)
groups = getFieldByNameOrError(tree, "MTPTimeGroupList");
timeGroups = zeros(length(groups.MTPTimeGroup), 2);
for i=1:length(groups.MTPTimeGroup)
    if(length(groups.MTPTimeGroup) == 1)
        group = groups.MTPTimeGroup;
    else
        group = groups.MTPTimeGroup{i};
    end
    if(~isempty(group.Text))
        timeGroups(i, :) = str2double(strsplit(group.Text, ' '));
    end
end
end

function params = getParams(tree)
params = struct();
paramArgs = ["preprocess_emg", "preprocess_emg_filter_degree", ...
    "preprocess_emg_high_pass_cutoff", "preprocess_emg_low_pass_cutoff"];
% name in matlab is different, use for output struct arg name
paramName = ["processEmg", "filterDegree", "highPassCutoff", ...
    "lowPassCutoff"];
preprocessEmg = getFieldByName(tree, paramArgs(1));
if(isstruct(preprocessEmg))
    params.(paramName(1)) = strcmpi(preprocessEmg.Text, 'true');
end
for i=2:length(paramArgs)
    value = getFieldByName(tree, paramArgs(i));
    if(isstruct(value))
        params.(paramName(i)) = str2double(value.Text);
    end
end
end

