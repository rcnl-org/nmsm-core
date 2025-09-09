% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a JMP settings file and produces plots of marker
% matching, and prints error values to the command window.
%
% (string) -> (None)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function plotJmpResultsFromSettingsFile(settingsFileName, extraMarkerFiles)
import org.opensim.modeling.Storage
try 
    verifyProjectOpened()
catch
    error("NMSM Pipeline Project is not opened.")
end
settingsTree = xml2struct(settingsFileName);
[outputModelFileName, inputs, ~] = ...
    parseJointModelPersonalizationSettingsTree(settingsTree);

inputModelFileName = inputs.modelFileName;
[~, settingsFileNameNoExt, ~] = fileparts(settingsFileName);
if ~exist("MarkerErrors", "dir")
    mkdir("MarkerErrors")
end
markerNames = [];
for i = 1 : numel(inputs.tasks)
    task = inputs.tasks{i};
    markerNames = [markerNames, task.markerNames];
    initialErrorFile = fullfile("MarkerErrors", ...
        strcat(settingsFileNameNoExt, "_task_", num2str(i), ...
        "_initialErrors.sto"));
    finalErrorFile = fullfile("MarkerErrors", ...
        strcat(settingsFileNameNoExt, "_task_", num2str(i), ...
        "_finalErrors.sto"));
    % Calculate marker errors
    reportDistanceErrorByMarker(inputModelFileName, ...
        task.markerFile, task.markerNames, initialErrorFile, ...
        [task.startTime task.finishTime]);
    reportDistanceErrorByMarker(outputModelFileName, ...
        task.markerFile, task.markerNames, finalErrorFile, ...
        [task.startTime task.finishTime]);
    % Plot marker errors
    plotMarkerDistanceErrors([initialErrorFile, finalErrorFile], false)


end
markerNames = unique(markerNames);
if nargin > 1
for j = 1 : numel(extraMarkerFiles)
    [~, markerFileName, ~] = fileparts(extraMarkerFiles(j));
    initialErrorFile = fullfile("MarkerErrors", ...
        strcat(settingsFileNameNoExt, "_", markerFileName, ...
        "_initialErrors.sto"));
    finalErrorFile = fullfile("MarkerErrors", ...
        strcat(settingsFileNameNoExt, "_", markerFileName, ...
        "_finalErrors.sto"));
    reportDistanceErrorByMarker(inputModelFileName, ...
        extraMarkerFiles(j), markerNames, initialErrorFile);
    reportDistanceErrorByMarker(outputModelFileName, ...
        extraMarkerFiles(j), markerNames, finalErrorFile);
    plotMarkerDistanceErrors([initialErrorFile, finalErrorFile], false)
end
end
end