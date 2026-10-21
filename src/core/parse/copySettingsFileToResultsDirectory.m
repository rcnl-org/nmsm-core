% This function is part of the NMSM Pipeline, see file for full license.
%
% (string, string) -> (None)
% Saves the settings file for the run to the results directory

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert M. Salati                                             %
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

function copySettingsFileToResultsDirectory(settingsFileName, resultsDirectory)
try
    [~, settingsFile, ext] = fileparts(settingsFileName);
    copyfile(settingsFileName, fullfile(resultsDirectory, strcat(settingsFile, ext)));
catch
    warning("Could not copy settings file to results directory. Results were still saved");
end
end