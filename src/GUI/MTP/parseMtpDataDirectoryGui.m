% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses an MTP data directory: trial prefixes are derived
% from subfolders inside MAData that contain at least one .sto file.
% Other data folders (EMGData, IDData, IKData) have flat .sto files named
% {trialPrefix}.sto. EMG and ID channel labels are parsed from those trials
% and populated into the GUI for muscle group configuration.
%
% (App, string) -> ()
% Parses MTP data directory and populates trial prefixes and channel labels

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
function parseMtpDataDirectoryGui(app, dataDirectory)
import org.opensim.modeling.Storage
import org.opensim.modeling.Model

if strcmp(dataDirectory, "") || ~exist(dataDirectory, "dir")
    return
end

maDataPath = fullfile(dataDirectory, "MAData");
if ~exist(maDataPath, "dir")
    return
end

trialNames = findPrefixesFromSubdirectories(maDataPath);

if isempty(trialNames)
    return
end

try
    emgNames = {};
    for i = 1:length(trialNames)
        [emgNames{i}, ~, ~] = parseMotToComponents( ...
            org.opensim.modeling.Model(), ...
            Storage(fullfile(dataDirectory, "EMGData", ...
            strcat(trialNames(i), ".sto"))));
    end
    app.setEmgLabels(emgNames{1});
catch
end

try
    idNames = {};
    for i = 1:length(trialNames)
        [idNames{i}, ~, ~] = parseMotToComponents( ...
            org.opensim.modeling.Model(), ...
            Storage(fullfile(dataDirectory, "IDData", ...
            strcat(trialNames(i), ".sto"))));
    end
    app.setIDLabels(idNames{1});
catch
end

end
