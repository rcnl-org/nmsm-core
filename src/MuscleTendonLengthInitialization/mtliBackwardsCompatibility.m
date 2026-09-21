% This function is part of the NMSM Pipeline, see file for full license.
%
% This function renames the cost terms of the MuscleTendonLengthInitialization
% element of Muscle Tendon Personalization and Neural Control Personalization
% settings files written for version 1.5 or earlier to the names used by
% the current version. Files for later versions are left unchanged.
% Renaming is safe to repeat because no current name is a legacy name.
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

function settingsTree = mtliBackwardsCompatibility(settingsTree)
if ~isstruct(settingsTree) || ~isfield(settingsTree, "NMSMPipelineDocument")
    return
end
document = settingsTree.NMSMPipelineDocument;
if ~isLegacySettingsFileVersion(document)
    return
end
renames = mtliCostTermRenames();
for toolName = ["MuscleTendonPersonalizationTool", ...
        "NeuralControlPersonalizationTool"]
    if isfield(document, toolName) && isstruct(document.(toolName)) && ...
            isfield(document.(toolName), "MuscleTendonLengthInitialization")
        document.(toolName).MuscleTendonLengthInitialization = ...
            renameCostTermSet( ...
            document.(toolName).MuscleTendonLengthInitialization, renames);
    end
end
settingsTree.NMSMPipelineDocument = document;
end

function renames = mtliCostTermRenames()
renames = containers.Map( ...
    {'passive_joint_moment', ...
    'optimal_muscle_fiber_length', ...
    'tendon_slack_length', ...
    'minimum_normalized_muscle_fiber_length', ...
    'maximum_normalized_muscle_fiber_length', ...
    'maximum_muscle_stress', ...
    'passive_muscle_force', ...
    'grouped_normalized_muscle_fiber_length', ...
    'grouped_maximum_normalized_muscle_fiber_length'}, ...
    {'passive_joint_moment_tracking', ...
    'optimal_fiber_length_deviation', ...
    'tendon_slack_length_deviation', ...
    'minimum_normalized_fiber_length_deviation', ...
    'maximum_normalized_fiber_length_deviation', ...
    'maximum_muscle_stress_deviation', ...
    'passive_force_minimization', ...
    'grouped_normalized_fiber_length_similarity', ...
    'grouped_maximum_normalized_fiber_length_similarity'});
end
