% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a data directory for use in the GUI. It checks
% that the directory exists, that each required subfolder is present, that
% each subfolder contains at least one .sto file, and that the first .sto
% file in each subfolder can be loaded. The requiredSubfolders parameter is
% a string array so different tools can pass their own subfolder lists.
%
% (string, string[], UIComponent, UIComponent) -> (bool)
% Validates a data directory structure and wires result to GUI error components

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
function isValid = validateDataDirectoryGui(dataDir, requiredSubfolders, fieldObj, iconObj)
import org.opensim.modeling.Storage
if strcmp(dataDir, "")
    clearGuiError(fieldObj, iconObj);
    isValid = false;
    return
end
if ~exist(dataDir, "dir")
    throwGuiError("The given data directory does not exist. Check the path and try again.", fieldObj, iconObj);
    isValid = false;
    return
end
for i = 1:length(requiredSubfolders)
    subfolder = requiredSubfolders(i);
    subpath = fullfile(dataDir, subfolder);
    if ~exist(subpath, "dir")
        throwGuiError("The data directory must contain a folder named '" + subfolder + "'.", fieldObj, iconObj);
        isValid = false;
        return
    end
    files = dir(fullfile(subpath, "*.sto"));
    stoPath = subpath;
    if isempty(files)
        % Some subfolders (e.g. MAData) store .sto files one level deeper
        % in per-trial subfolders rather than directly.
        subEntries = dir(subpath);
        subEntries = subEntries([subEntries.isdir]);
        subEntries = subEntries(~ismember({subEntries.name}, {'.', '..'}));
        for j = 1:length(subEntries)
            candidateFiles = dir(fullfile(subpath, subEntries(j).name, "*.sto"));
            if ~isempty(candidateFiles)
                files = candidateFiles;
                stoPath = fullfile(subpath, subEntries(j).name);
                break
            end
        end
    end
    if isempty(files)
        throwGuiError("The '" + subfolder + "' folder contains no .sto data files.", fieldObj, iconObj);
        isValid = false;
        return
    end
    try
        Storage(fullfile(stoPath, files(1).name));
    catch
        throwGuiError("A file in '" + subfolder + "' could not be loaded. Verify that it is a valid .sto file.", fieldObj, iconObj);
        isValid = false;
        return
    end
end
clearGuiError(fieldObj, iconObj);
isValid = true;
end
