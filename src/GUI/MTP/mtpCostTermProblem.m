% This function is part of the NMSM Pipeline, see file for full license.
%
% This function checks one MTP task cost term against the settings it
% depends on. Only enabled terms are checked. An error is returned for a
% term the core cannot use, and a warning for a term that is legal but has
% no effect. The reason states only the problem; the caller adds the term
% name.
%
% The context struct has these fields:
%   activationGroups, fiberLengthGroups, collectedEmgGroups,
%   missingEmgGroups - string arrays of muscle group names
%   synxEnabled - logical, synergy extrapolation is enabled
%   muscleSpecificDelays - logical, muscle specific electromechanical
%       delays are used
%   isOptimized - struct of logicals, one per design variable:
%       electromechanicalDelays, activationTimeConstants,
%       activationNonlinearityConstants, emgScaleFactors,
%       optimalFiberLengths, tendonSlackLengths
%
% (RCNLCostTermClass, struct) -> (string, string)
% returns "error", "warning" or "" with the reason the term has a problem

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
function [severity, reason] = mtpCostTermProblem(term, context)
severity = "";
reason = "";
if ~strcmp(term.is_enabled, 'true')
    return
end
maxError = term.max_allowable_error;
if ~isnumeric(maxError) || ~isscalar(maxError) || isnan(maxError) || ...
        maxError <= 0
    severity = "error";
    reason = "max allowable error must be greater than zero";
    return
end
type = string(term.type);
reason = missingGroupReason(type, context);
if strlength(reason) > 0
    severity = "error";
    return
end
if type == "grouped_electromechanical_delay_similarity" && ...
        ~context.muscleSpecificDelays
    severity = "warning";
    reason = "has no effect while muscle_specific_electromechanical_delays " + ...
        "is false (Advanced tab)";
    return
end
if type == "muscle_excitation_minimization" && ~context.synxEnabled
    severity = "warning";
    reason = "has no effect unless synergy extrapolation is enabled " + ...
        "(Synergy Extrapolation tab)";
    return
end
[field, label] = optimizedParameter(type);
if strlength(field) > 0 && ~context.isOptimized.(field)
    severity = "warning";
    reason = label + " are not optimized in this task, so this term " + ...
        "is constant";
    return
end
reason = "";
end

function reason = missingGroupReason(type, context)
reason = "";
switch type
    case {"grouped_activation_similarity", ...
            "grouped_activation_time_constant_similarity", ...
            "grouped_activation_nonlinearity_similarity"}
        if isEmptyStringList(context.activationGroups)
            reason = "requires at least one activation muscle group " + ...
                "(Muscle Groups tab)";
        end
    case "grouped_normalized_fiber_length_similarity"
        if isEmptyStringList(context.fiberLengthGroups)
            reason = "requires at least one normalized fiber length " + ...
                "muscle group (Muscle Groups tab)";
        end
    case {"grouped_emg_scale_factor_similarity", ...
            "grouped_electromechanical_delay_similarity"}
        % The core groups these by the collected EMG groups, plus the
        % missing EMG groups when synergy extrapolation is enabled
        hasEmgGroups = ~isEmptyStringList(context.collectedEmgGroups) || ...
            (context.synxEnabled && ...
            ~isEmptyStringList(context.missingEmgGroups));
        if ~hasEmgGroups
            reason = "requires at least one collected EMG muscle group, " + ...
                "or a missing EMG muscle group while synergy " + ...
                "extrapolation is enabled (Muscle Groups tab)";
        end
end
end

function [field, label] = optimizedParameter(type)
field = "";
label = "";
switch type
    case {"emg_scale_factor_deviation", "grouped_emg_scale_factor_similarity"}
        field = "emgScaleFactors";
        label = "EMG scale factors";
    case {"electromechanical_delay_deviation", ...
            "grouped_electromechanical_delay_similarity"}
        field = "electromechanicalDelays";
        label = "Electromechanical delays";
    case {"activation_time_constant_deviation", ...
            "grouped_activation_time_constant_similarity"}
        field = "activationTimeConstants";
        label = "Activation time constants";
    case {"activation_nonlinearity_deviation", ...
            "grouped_activation_nonlinearity_similarity"}
        field = "activationNonlinearityConstants";
        label = "Activation non-linearity constants";
    case "optimal_fiber_length_deviation"
        field = "optimalFiberLengths";
        label = "Optimal fiber lengths";
    case "tendon_slack_length_deviation"
        field = "tendonSlackLengths";
        label = "Tendon slack lengths";
end
end
