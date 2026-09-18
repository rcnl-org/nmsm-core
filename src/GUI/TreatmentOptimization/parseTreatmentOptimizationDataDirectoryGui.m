% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses a Treatment Optimization tracked quantities
% directory. Trial names are derived from the file names inside IDData,
% falling back to IKData, matching the convention of findPrefixes. The
% column labels of the selected trial's data files are parsed and
% populated into the GUI, where they determine which components may be
% selected for the states coordinate list, the controllers, and later the
% cost and constraint terms.
%
% IKData and IDData are always expected. MAData supplies the muscle list
% and GRFData is only needed for ground reaction cost terms, so a missing
% folder is never treated as an error here. Note that the MAData a run
% actually reads comes from the surrogate model data directory, not from
% here; see parseSurrogateModelData.
%
% (App, string, string) -> (string array)
% Parses a tracked quantities directory and populates its data labels

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
function trialNames = parseTreatmentOptimizationDataDirectoryGui(app, ...
    dataDirectory, trialName)
trialNames = string([]);
if strcmp(dataDirectory, "") || ~exist(dataDirectory, "dir")
    return
end

trialNames = findTrialNames(dataDirectory);
if isempty(trialNames)
    return
end
if nargin < 3 || strcmp(trialName, "") || ~any(strcmp(trialNames, trialName))
    trialName = trialNames(1);
end

try
    app.setTrackedCoordinateLabels( ...
        parseTrialColumnLabels(dataDirectory, "IKData", trialName));
catch
end

try
    app.setTrackedLoadLabels( ...
        parseTrialColumnLabels(dataDirectory, "IDData", trialName));
catch
end

try
    app.setTrackedEmgLabels( ...
        parseTrialColumnLabels(dataDirectory, "EMGData", trialName));
catch
end

try
    app.setTrackedGrfLabels( ...
        parseTrialColumnLabels(dataDirectory, "GRFData", trialName));
catch
end

try
    [coordinates, muscles] = parseMomentArmData(dataDirectory, trialName);
    app.setTrackedMomentArmCoordinates(coordinates);
    app.setTrackedMomentArmMuscles(muscles);
catch
end
end

function trialNames = findTrialNames(dataDirectory)
files = dir(fullfile(dataDirectory, "IDData"));
if isempty(files)
    files = dir(fullfile(dataDirectory, "IKData"));
end

trialNames = string([]);
for i = 1:length(files)
    if ~files(i).isdir
        [~, name, ~] = fileparts(files(i).name);
        trialNames(end+1) = name;
    end
end
end

function columnLabels = parseTrialColumnLabels(dataDirectory, subfolder, ...
    trialName)
import org.opensim.modeling.Storage
import org.opensim.modeling.Model
[columnLabels, ~, ~] = parseMotToComponents(Model(), ...
    Storage(findTrialFile(fullfile(dataDirectory, subfolder), trialName)));
end

% The trial file extension varies between .sto and .mot, so match on the
% file name without it.
function filePath = findTrialFile(directory, trialName)
files = dir(directory);
for i = 1:length(files)
    [~, name, ~] = fileparts(files(i).name);
    if ~files(i).isdir && strcmp(name, trialName)
        filePath = fullfile(directory, files(i).name);
        return
    end
end
% The message is built with a format specifier so that file separators in
% the directory are not read as escape characters
throw(MException("ParseError:TrialNameFile", "%s", ...
    strcat("No file named ", trialName, " was found in ", directory)))
end

% Moment arm data is stored as MAData/<trialName>/MomentArm_<coordinate>.sto
% with one column per muscle, as expected by parseSelectMomentArms.
function [coordinates, muscles] = parseMomentArmData(dataDirectory, trialName)
import org.opensim.modeling.Storage
coordinates = string([]);
muscles = string([]);
directory = fullfile(dataDirectory, "MAData", trialName);
if ~exist(directory, "dir")
    return
end

files = dir(fullfile(directory, "MomentArm_*.sto"));
for i = 1:length(files)
    [~, name, ~] = fileparts(files(i).name);
    coordinates(end+1) = erase(name, "MomentArm_");
    if isempty(muscles)
        try
            muscles = getStorageColumnNames( ...
                Storage(fullfile(directory, files(i).name)));
        catch
        end
    end
end
end
