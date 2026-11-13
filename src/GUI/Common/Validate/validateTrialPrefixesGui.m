% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (Array of string, string, UIComponent, UIComponent) -> (logical)
% Validates trial prefixes against the data directory contents

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
function isValid = validateTrialPrefixesGui(trialPrefixes, ...
    dataDirectory, fieldObject, errorIcon)
requiredFilePatterns = ["*_Length.sto", "*_Velocity.sto", ...
    "*MomentArm_*.sto"];
if isEmptyStringList(trialPrefixes)
    message = "No trial prefixes specified. All trials in the data " + ...
        "directory will be used.";
    problems = findMaDataTrialProblemsGui(dataDirectory, ...
        idDataTrialNames(dataDirectory), requiredFilePatterns);
    isValid = isempty(problems);
    if isValid
        throwGuiWarning(message, fieldObject, errorIcon);
    else
        throwGuiError(strjoin([message; problems], newline), ...
            fieldObject, errorIcon);
    end
    return
end
problems = findMaDataTrialProblemsGui(dataDirectory, trialPrefixes, ...
    requiredFilePatterns);
isValid = isempty(problems);
if isValid
    clearGuiError(fieldObject, errorIcon);
else
    throwGuiError(strjoin(problems, newline), fieldObject, errorIcon);
end
end

% The trials findPrefixes uses when no prefixes are given: the name of
% each file in IDData without its extension
function names = idDataTrialNames(dataDirectory)
names = strings(0, 1);
if strcmp(dataDirectory, "")
    return
end
files = dir(fullfile(dataDirectory, "IDData"));
files = files(~[files.isdir] & ~startsWith({files.name}, "."));
for i = 1 : numel(files)
    [~, names(end + 1)] = fileparts(files(i).name); %#ok<AGROW>
end
end
