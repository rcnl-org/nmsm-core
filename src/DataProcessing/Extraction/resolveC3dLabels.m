% This function is part of the NMSM Pipeline, see file for full license.
%
% Chooses the names used for c3d points or analog channels. The LABELS
% parameter is used when its entries are unique and non-empty. Some capture
% software (e.g. Cortex) writes labels truncated to four characters, which
% makes them repeat, and stores the full names in DESCRIPTIONS. In that
% case the descriptions are used instead if they are unique and non-empty.
% Otherwise an error lists the repeated labels. Whitespace inside a name is
% replaced with an underscore so names are valid in .trc and .sto headers.
%
% (Array of string, struct, string) -> (Array of string)
% Returns unique names for the columns of a c3d table

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

function names = resolveC3dLabels(tableLabels, parameters, groupName)
names = sanitize(tableLabels);
if areValidNames(names)
    return
end
labels = getC3dParameter(parameters, groupName, "LABELS");
descriptions = sanitize(getC3dParameter(parameters, groupName, ...
    "DESCRIPTIONS"));
if numel(labels) == numel(names) && numel(descriptions) == numel(names) ...
        && areValidNames(descriptions)
    warning("resolveC3dLabels:usingDescriptions", ...
        "%s:LABELS in the c3d file are empty or repeated, so " + ...
        "%s:DESCRIPTIONS are used as names instead.", groupName, groupName);
    names = descriptions;
    return
end
throw(MException("resolveC3dLabels:repeatedLabels", ...
    "%s labels in the c3d file are empty or repeated and no usable " + ...
    "descriptions exist. Repeated or empty labels: %s", groupName, ...
    strjoin(unique(names(isRepeatedOrEmpty(names))), ", ")))
end

function names = sanitize(names)
names = regexprep(strtrim(string(names)), "\s+", "_");
end

function valid = areValidNames(names)
valid = ~isempty(names) && ~any(isRepeatedOrEmpty(names));
end

function bad = isRepeatedOrEmpty(names)
[~, ~, groups] = unique(names);
counts = accumarray(groups(:), 1);
bad = names == "" | (counts(groups) > 1)';
end
