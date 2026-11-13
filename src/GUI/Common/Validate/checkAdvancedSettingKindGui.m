% This function is part of the NMSM Pipeline, see file for full license.
%
% This function checks one advanced setting against the kind of value its
% table row takes, and states the rule it breaks. Each tool lists a kind
% for every row of its advanced settings table, so which settings may be
% zero is decided by that list rather than by each tool's own checks.
%
% Kinds:
%   "positive"           a number greater than zero
%   "nonnegative"        zero or a positive number, for settings where
%                        zero is meaningful, such as an initial guess
%   "positiveInteger"    a whole number greater than zero
%   "nonnegativeInteger" zero or a positive whole number, such as an
%                        iteration limit, where zero stops the
%                        optimization immediately
%   "boolean"            true or false, in any case
%
% (string, string) -> (logical, string)
% Checks an advanced setting value against its kind

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
function [isValid, reason] = checkAdvancedSettingKindGui(value, kind)
value = strtrim(string(value));
number = str2double(value);
isNumber = ~isnan(number);
isWhole = isNumber && mod(number, 1) == 0;
switch kind
    case "positive"
        isValid = isNumber && number > 0;
        reason = "must be a positive number";
    case "nonnegative"
        isValid = isNumber && number >= 0;
        reason = "must be zero or a positive number";
    case "positiveInteger"
        isValid = isWhole && number > 0;
        reason = "must be a positive integer";
    case "nonnegativeInteger"
        isValid = isWhole && number >= 0;
        reason = "must be zero or a positive integer";
    case "boolean"
        % Written lowercase on save, so any casing is accepted
        isValid = any(strcmpi(value, ["true", "false"]));
        reason = "must be true or false";
    otherwise
        error("checkAdvancedSettingKindGui:badKind", ...
            "Unknown advanced setting kind ""%s""", kind);
end
if isValid
    reason = "";
end
end
