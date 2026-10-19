% This function is part of the NMSM Pipeline, see file for full license.
%
% This function lays the cost terms loaded from a settings file over a
% tool's default cost terms. Every default term is kept, in the default
% order, so a file that lists only some of the terms still shows all of
% them. A loaded term replaces the default of the same type. A loaded type
% with no default is kept at the end rather than dropped.
%
% (Cell Array of RCNLCostTermClass, Cell Array of RCNLCostTermClass) ->
%     (Cell Array of RCNLCostTermClass)
% Merges loaded cost terms into the default cost terms

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
function merged = mergeLoadedCostTerms(defaultTerms, loadedTerms)
merged = defaultTerms;
types = strings(1, numel(merged));
for i = 1 : numel(merged)
    types(i) = string(merged{i}.type);
end
filled = false(1, numel(merged));
for i = 1 : numel(loadedTerms)
    term = loadedTerms{i};
    if isempty(term)
        continue
    end
    type = string(term.type);
    index = find(types == type, 1);
    if isempty(index)
        merged{end + 1} = term; %#ok<AGROW>
        types(end + 1) = type; %#ok<AGROW>
        filled(end + 1) = true; %#ok<AGROW>
        continue
    end
    % When a file lists a type twice, the enabled entry is kept
    if filled(index) && ~strcmp(term.is_enabled, 'true')
        continue
    end
    % A file omits <error_center> for a term that does not use one, so the
    % default center is kept for terms that now do
    if index <= numel(defaultTerms)
        defaultTerm = defaultTerms{index};
        if ~term.uses_error_center && defaultTerm.uses_error_center
            term.error_center = defaultTerm.error_center;
            term.uses_error_center = true;
        end
    end
    merged{index} = term;
    filled(index) = true;
end
end
