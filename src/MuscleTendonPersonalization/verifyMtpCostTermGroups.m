% This function is part of the NMSM Pipeline, see file for full license.
%
% This function throws an error when an enabled grouped similarity cost
% term in an enabled MTP task has no muscle groups to compare. Without
% groups, the activation and normalized fiber length terms fail inside the
% optimization and the EMG parameter terms silently add no cost. The
% groups each term needs match the checks in the MTP GUI.
%
% (struct) -> (None)
% throws an error if a grouped term is enabled and its groups are empty

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

function verifyMtpCostTermGroups(inputs)
for i = 1 : length(inputs.tasks)
    costTerms = inputs.tasks{i}.costTerms;
    for j = 1 : length(costTerms)
        if ~costTerms{j}.isEnabled
            continue
        end
        [groups, groupSource] = getRequiredGroups(inputs, ...
            costTerms{j}.type);
        if strlength(groupSource) > 0 && ~hasGroups(groups)
            throw(MException('', "The " + costTerms{j}.type + ...
                " cost term requires at least one muscle group in " + ...
                groupSource + ". Add a group or disable the term."))
        end
    end
end
end

% Returns the groups a cost term compares and the setting they come from,
% or an empty source if the term does not use groups
function [groups, groupSource] = getRequiredGroups(inputs, type)
groups = {};
groupSource = "";
switch type
    case {"grouped_activation_similarity", ...
            "grouped_activation_time_constant_similarity", ...
            "grouped_activation_nonlinearity_similarity"}
        groups = inputs.activationGroups;
        groupSource = "activation_muscle_groups";
    case "grouped_normalized_fiber_length_similarity"
        groups = inputs.normalizedFiberLengthGroups;
        groupSource = "normalized_fiber_length_muscle_groups";
    case {"grouped_emg_scale_factor_similarity", ...
            "grouped_electromechanical_delay_similarity"}
        groups = inputs.emgParameterGroups;
        groupSource = "collected_emg_channel_muscle_groups (or " + ...
            "missing_emg_channel_muscle_groups when synergy " + ...
            "extrapolation is enabled)";
end
end

function result = hasGroups(groups)
result = ~isempty(groups) && ~all(cellfun(@isempty, groups));
end
