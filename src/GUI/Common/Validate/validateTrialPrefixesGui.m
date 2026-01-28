% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates that each given trial prefix matches a trial in
% the data directory's MAData subdirectory. Empty prefixes and missing
% data directories are treated as valid so this check only fires once
% both fields hold values.
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
isValid = true;
clearGuiError(fieldObject, errorIcon);
if isEmptyStringList(trialPrefixes)
    return
end
if strcmp(dataDirectory, "") || ...
        ~exist(fullfile(dataDirectory, "MAData"), "dir")
    return
end
available = findPrefixesFromSubdirectories( ...
    fullfile(dataDirectory, "MAData"));
invalid = trialPrefixes(~ismember(trialPrefixes, available));
if ~isempty(invalid)
    throwGuiError("Trial prefix(es) not found in data directory: " + ...
        strjoin(invalid, ", "), fieldObject, errorIcon);
    isValid = false;
end
end
