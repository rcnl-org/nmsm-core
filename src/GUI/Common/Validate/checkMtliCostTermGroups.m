% This function is part of the NMSM Pipeline, see file for full license.
%
% This function finds the enabled Muscle Tendon Length Initialization cost
% terms that need normalized fiber length muscle groups when there are
% none. Only grouped_normalized_fiber_length_similarity needs them: the
% grouped maximum normalized fiber length term gives every muscle outside
% a group its own value, so it still works without groups.
%
% (cell array of RCNLCostTermClass, string) -> (Array of integer)
% returns the cost term indices that need a normalized fiber length group

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

function invalidIndices = checkMtliCostTermGroups(costTerms, ...
    normalizedFiberLengthGroups)
invalidIndices = [];
if ~isEmptyStringList(normalizedFiberLengthGroups)
    return
end
for i = 1:length(costTerms)
    if ~isempty(costTerms{i}) && strcmp(costTerms{i}.is_enabled, 'true') ...
            && strcmp(string(costTerms{i}.type), ...
            "grouped_normalized_fiber_length_similarity")
        invalidIndices(end + 1) = i; %#ok<AGROW>
    end
end
end
