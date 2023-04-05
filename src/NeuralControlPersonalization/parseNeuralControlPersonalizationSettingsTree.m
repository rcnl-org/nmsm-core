% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the necessary inputs and produces the results of IK,
% ID, and MuscleAnalysis so the values can be used as inputs for
% MuscleTendonPersonalization.
%
% (struct, struct) -> (None)
% Prepares raw data for MuscleTendonPersonalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function [inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree, inputs.model, inputs);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end

function inputs = getInputs(tree)
inputs = parseMtpNcpSharedInputs(tree);
inputs.synergyGroups = getSynergyGroups(tree, Model(inputs.model));
inputs = matchMuscleNamesFromCoordinatesAndSynergyGroups(inputs);
inputs = loadMtpData(tree, inputs);
inputs = reorderPreprocessedDataByMuscleNames(inputs, inputs.muscleNames);
[inputs.maxIsometricForce, inputs.optimalFiberLength, ...
    inputs.tendonSlackLength, inputs.pennationAngle] = ...
    getMuscleInputs(inputs, inputs.muscleTendonColumnNames);
[inputs.optimalFiberLengthScaleFactors, ...
    inputs.tendonSlackLengthScaleFactors] = getMtpDataInputs( ...
    inputs.mtpMuscleData, inputs.muscleTendonColumnNames);
end

function inputs = loadMtpData(tree, inputs)
mtpResultsDirectory = getFieldByNameOrError( ...
    tree, "mtp_results_directory_1").Text;
[inputs.mtpActivations, inputs.mtpActivationsColumnNames] = ...
    parseMtpStandard(findFileListFromPrefixList( ...
    fullfile(mtpResultsDirectory, "muscleActivations"), inputs.prefixes));
inputs.mtpMuscleData = parseOsimxFile(fullfile(mtpResultsDirectory, ...
    "model.osimx"));
% Remove activations of muscles from coordinates not included
includedSubset = ismember(inputs.mtpActivationsColumnNames, ...
    inputs.muscleTendonColumnNames);
inputs.mtpActivationsColumnNames = ...
    inputs.mtpActivationsColumnNames(includedSubset);
inputs.mtpActivations = inputs.mtpActivations(:, includedSubset, :);
end

function [maxIsometricForce, optimalFiberLength, tendonSlackLength, ...
    pennationAngle] = getMuscleInputs(inputs, muscles)
optimalFiberLength = zeros(1, length(muscles));
tendonSlackLength = zeros(1, length(muscles));
pennationAngle = zeros(1, length(muscles));
maxIsometricForce = zeros(1, length(muscles));
model = Model(inputs.model);
for i = 1:length(muscles)
    optimalFiberLength(i) = model.getForceSet(). ...
        getMuscles().get(muscles(i)).getOptimalFiberLength();
    tendonSlackLength(i) = model.getForceSet(). ...
        getMuscles().get(muscles(i)).getTendonSlackLength();
    pennationAngle(i) = model.getForceSet().getMuscles() ...
        .get(muscles(i)).getPennationAngleAtOptimalFiberLength();
    maxIsometricForce(i) = model.getForceSet(). ...
        getMuscles().get(muscles(i)).getMaxIsometricForce();
end
end

function params = getParams(tree, model, inputs)
model = Model(model);
params = struct();
params.activationGroupNames = parseSpaceSeparatedList(tree, ...
    'activation_muscle_groups');
params.activationGroups = groupNamesToGroups( ...
    params.activationGroupNames, model);
params.normalizedFiberLengthGroupNames = parseSpaceSeparatedList(tree, ...
    'normalized_fiber_length_muscle_groups');
params.normalizedFiberLengthGroups = groupNamesToGroups( ...
    params.normalizedFiberLengthGroupNames, model);
costTermFieldNames = ["momentTracking", "activationTracking", ...
    "activationMinimization", "groupedActivations", ...
    "groupedFiberLengths", "bilateralSymmetry"];
costTermTypes = ["moment_tracking", "activation_tracking", ...
    "activation_minimization", "grouped_activations", ...
    "grouped_fiber_lengths", "bilateral_symmetry"];
params = parseRcnlCostTermSet( ...
    getFieldByNameOrError(tree, 'RCNLCostTermSet').objects.RCNLCostTerm,...
    params, costTermFieldNames, costTermTypes);
if params.costTerms.bilateralSymmetry.isEnabled && ...
    length(inputs.synergyGroups) ~= 2
    throw(MException('', ['Bilateral symmetry cost requires exactly ' ...
        'two synergy groups.']))
end
end

function groups = getSynergyGroups(tree, model)
synergySetTree = getFieldByNameOrError(tree, "RCNLSynergySet");
groupsTree = getFieldByNameOrError(synergySetTree, "objects").RCNLSynergy;
groups = {};
for i=1:length(groupsTree)
    if(length(groupsTree) == 1)
        group = groupsTree;
    else
        group = groupsTree{i};
    end
    groups{i}.numSynergies = ...
        str2double(group.num_synergies.Text);
    groupMembers = model.getForceSet().getGroup( ...
        group.muscle_group_name.Text).getMembers();
    muscleNames = string([]);
    for j=0:groupMembers.getSize() - 1
        muscleNames(end + 1) = groupMembers.get(j);
    end
    groups{i}.muscleNames = muscleNames;
    groups{i}.muscleGroupName = group.muscle_group_name.Text;
end
end

function [optimalFiberLengthScaleFactors, ...
    tendonSlackLengthScaleFactors] = getMtpDataInputs(mtpData, muscleNames)
optimalFiberLengthScaleFactors = zeros(1, length(muscleNames));
tendonSlackLengthScaleFactors = zeros(1, length(muscleNames));
mtpDataMuscleNames = fieldnames(mtpData);
for i = 1 : length(muscleNames)
    if ismember(muscleNames(i), mtpDataMuscleNames)
        optimalFiberLengthScaleFactors(i) = mtpData.(muscleNames(i)).optimalFiberLengthScaleFactor;
        tendonSlackLengthScaleFactors(i) = mtpData.(muscleNames(i)).tendonSlackLengthScaleFactor;
    else
        optimalFiberLengthScaleFactors(i) = 1;
        tendonSlackLengthScaleFactors(i) = 1;
    end
end
end
