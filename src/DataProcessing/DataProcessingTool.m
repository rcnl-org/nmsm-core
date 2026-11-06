% This function is part of the NMSM Pipeline, see file for full license.
%
% Data Processing is the first step of the NMSM Pipeline. It reads a .c3d
% file and writes its marker, ground reaction, and EMG data to .trc and
% .sto files.
%
% (string, App) -> (None)
% Runs Data Processing from a settings file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
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

function DataProcessingTool(settingsFileName, app)
tic
try
    verifyProjectOpened()
catch
    error("NMSM Pipeline Project is not opened.")
end
if nargin < 2
    app = [];
end
settingsTree = xml2struct(settingsFileName);
verifyVersion(settingsTree, "DataProcessingTool");
[inputs, params, resultsDirectory] = ...
    parseDataProcessingSettingsTree(settingsTree);
updateRunStageGui(app, 'ParsingLabel', 'off');
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
copySettingsFileToResultsDirectory(settingsFileName, resultsDirectory);
outputLogFile = fullfile("commandWindowOutput.txt");
diary(outputLogFile)
try
    results = DataProcessing(inputs, params, app);
    updateRunStageGui(app, 'SavingResultsLabel', 'on');
    saveDataProcessingResults(results, inputs, resultsDirectory);
    updateRunStageGui(app, 'SavingResultsLabel', 'off');
catch exception
    diary off
    moveLog(outputLogFile, resultsDirectory);
    rethrow(exception)
end
fprintf("Data Processing Runtime: %f Hours\n", toc / 3600);
diary off
moveLog(outputLogFile, resultsDirectory);
end

function moveLog(outputLogFile, resultsDirectory)
try
    movefile(outputLogFile, fullfile(resultsDirectory, outputLogFile));
catch
end
end
