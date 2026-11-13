% This function is part of the NMSM Pipeline, see file for full license.
%
% This function throws an error when the grouped normalized fiber length
% similarity cost term is enabled but there are no normalized fiber length
% muscle groups for it to compare. The grouped maximum normalized fiber
% length term is not checked because every muscle outside a group is
% given its own maximum normalized fiber length.
%
% (cell array of struct, cell array of array of number) -> (None)
% throws an error if grouped_normalized_fiber_length_similarity is enabled
% and the groups are empty

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

function verifyMtliNormalizedFiberLengthGroups(costTerms, ...
    normalizedFiberLengthGroups)
if ~isempty(normalizedFiberLengthGroups) && ...
        ~all(cellfun(@isempty, normalizedFiberLengthGroups))
    return
end
for i = 1 : length(costTerms)
    if costTerms{i}.isEnabled && strcmp(costTerms{i}.type, ...
            "grouped_normalized_fiber_length_similarity")
        throw(MException('', ['The grouped_normalized_fiber_length_' ...
            'similarity cost term requires at least one muscle group in ' ...
            'normalized_fiber_length_muscle_groups. Add a group or ' ...
            'disable the term.']))
    end
end
end
