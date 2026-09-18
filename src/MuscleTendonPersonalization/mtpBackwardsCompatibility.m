% This function is part of the NMSM Pipeline, see file for full license.
%
% This function renames the cost terms of Muscle Tendon Personalization
% settings files written for version 1.5 or earlier to the names used by
% the current version. Files for later versions, and the cost terms of
% Muscle Tendon Length Initialization, are left unchanged. Renaming is
% safe to repeat because no current name is a legacy name.
%
% (struct) -> (struct)
% returns the xml2struct settings tree with current cost term names

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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

function settingsTree = mtpBackwardsCompatibility(settingsTree)
if ~isstruct(settingsTree) || ~isfield(settingsTree, "NMSMPipelineDocument")
    return
end
document = settingsTree.NMSMPipelineDocument;
if ~isFileVersionLegacy(document) || ...
        ~isfield(document, "MuscleTendonPersonalizationTool") || ...
        ~isstruct(document.MuscleTendonPersonalizationTool)
    return
end
tool = document.MuscleTendonPersonalizationTool;
if isfield(tool, "MTPTaskList") && isstruct(tool.MTPTaskList) && ...
        isfield(tool.MTPTaskList, "MTPTask")
    tasks = tool.MTPTaskList.MTPTask;
    if iscell(tasks)
        for i = 1 : numel(tasks)
            tasks{i} = renameCostTermSet(tasks{i}, taskCostTermRenames());
        end
    else
        tasks = renameCostTermSet(tasks, taskCostTermRenames());
    end
    tool.MTPTaskList.MTPTask = tasks;
end
if isfield(tool, "MTPSynergyExtrapolation")
    tool.MTPSynergyExtrapolation = renameCostTermSet( ...
        tool.MTPSynergyExtrapolation, synergyExtrapolationCostTermRenames());
end
document.MuscleTendonPersonalizationTool = tool;
settingsTree.NMSMPipelineDocument = document;
end

% A file with no readable version is treated as legacy
function isLegacy = isFileVersionLegacy(document)
isLegacy = true;
if ~isstruct(document) || ~isfield(document, "Attributes") || ...
        ~isstruct(document.Attributes) || ...
        ~isfield(document.Attributes, "Version")
    return
end
numbers = str2double(split(string(document.Attributes.Version), "."));
if numel(numbers) < 2
    numbers(2) = 0;
end
if any(isnan(numbers(1:2)))
    return
end
isLegacy = numbers(1) < 1 || (numbers(1) == 1 && numbers(2) <= 5);
end

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

% When a file lists a legacy term and its successor side by side, the
% enabled entry is kept. If both or neither are enabled, the entry that
% already used the current name is kept.
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

function renames = taskCostTermRenames()
renames = containers.Map( ...
    {'inverse_dynamics_joint_moment', ...
    'passive_muscle_force', ...
    'muscle_excitation_penalty', ...
    'emg_scale_factor', ...
    'electromechanical_delay', ...
    'activation_time_constant', ...
    'activation_nonlinearity_constant', ...
    'optimal_muscle_fiber_length', ...
    'tendon_slack_length', ...
    'normalized_muscle_fiber_length', ...
    'minimum_normalized_muscle_fiber_length', ...
    'maximum_normalized_muscle_fiber_length', ...
    'grouped_normalized_muscle_fiber_length', ...
    'grouped_emg_scale_factor', ...
    'grouped_electromechanical_delay'}, ...
    {'inverse_dynamics_load_tracking', ...
    'passive_force_minimization', ...
    'muscle_excitation_minimization', ...
    'emg_scale_factor_deviation', ...
    'electromechanical_delay_deviation', ...
    'activation_time_constant_deviation', ...
    'activation_nonlinearity_deviation', ...
    'optimal_fiber_length_deviation', ...
    'tendon_slack_length_deviation', ...
    'normalized_fiber_length_deviation', ...
    'minimum_normalized_fiber_length_deviation', ...
    'maximum_normalized_fiber_length_deviation', ...
    'grouped_normalized_fiber_length_similarity', ...
    'grouped_emg_scale_factor_similarity', ...
    'grouped_electromechanical_delay_similarity'});
end

function renames = synergyExtrapolationCostTermRenames()
renames = containers.Map( ...
    {'measured_inverse_dynamics_joint_moment', ...
    'extrapolated_muscle_activation', ...
    'residual_muscle_activation'}, ...
    {'inverse_dynamics_load_tracking_SynX', ...
    'extrapolated_muscle_activation_minimization', ...
    'residual_muscle_activation_minimization'});
end
