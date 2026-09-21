% This function is part of the NMSM Pipeline, see file for full license.
%
% This function renames the cost terms of an element that holds an
% RCNLCostTermSet in an xml2struct settings tree. Each term whose type is
% a key of renames takes the mapped type. When a file lists a legacy term
% and its successor side by side, the enabled entry is kept. If both or
% neither are enabled, the entry that already used the current name is
% kept.
%
% (struct, containers.Map) -> (struct)
% returns the element with renamed cost terms

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

function parent = renameCostTermSet(parent, renames)
if ~isstruct(parent) || ~isfield(parent, "RCNLCostTermSet") || ...
        ~isstruct(parent.RCNLCostTermSet) || ...
        ~isfield(parent.RCNLCostTermSet, "RCNLCostTerm")
    return
end
terms = parent.RCNLCostTermSet.RCNLCostTerm;
if isstruct(terms)
    terms = {terms};
end
if ~iscell(terms)
    return
end
wasRenamed = false(1, numel(terms));
for i = 1 : numel(terms)
    type = getTermType(terms{i});
    if strlength(type) > 0 && isKey(renames, char(type))
        terms{i}.type.Text = renames(char(type));
        wasRenamed(i) = true;
    end
end
terms = removeCollisions(terms, wasRenamed);
% xml2struct keeps a single term as a bare struct, which the parsers expect
if isscalar(terms)
    terms = terms{1};
end
parent.RCNLCostTermSet.RCNLCostTerm = terms;
end

function terms = removeCollisions(terms, wasRenamed)
types = strings(1, numel(terms));
for i = 1 : numel(terms)
    types(i) = getTermType(terms{i});
end
remove = false(1, numel(terms));
for type = unique(types(wasRenamed))
    candidates = find(types == type);
    if numel(candidates) < 2
        continue
    end
    scores = zeros(1, numel(candidates));
    for j = 1 : numel(candidates)
        scores(j) = 2 * isTermEnabled(terms{candidates(j)}) + ...
            ~wasRenamed(candidates(j));
    end
    [~, keeper] = max(scores);
    remove(candidates) = true;
    remove(candidates(keeper)) = false;
end
terms = terms(~remove);
end

function type = getTermType(term)
type = "";
if isstruct(term) && isfield(term, "type") && isstruct(term.type) && ...
        isfield(term.type, "Text")
    type = string(term.type.Text);
end
end

function isEnabled = isTermEnabled(term)
isEnabled = isstruct(term) && isfield(term, "is_enabled") && ...
    isstruct(term.is_enabled) && isfield(term.is_enabled, "Text") && ...
    strcmpi(string(term.is_enabled.Text), "true");
end
