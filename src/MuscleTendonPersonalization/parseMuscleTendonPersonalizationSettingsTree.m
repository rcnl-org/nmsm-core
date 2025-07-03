% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Joint Model Personalization Settings XML file.
%
% (struct) -> (struct, struct, string)
% returns the input values for Muscle Tendon Personalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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
    parseMuscleTendonPersonalizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
inputs = getMtpModelInputs(inputs);
if isfield(inputs, "synergyExtrapolation")
    inputs = mergeStructs(getSynergyExtrapolationInputs(...
        inputs.model, ...
        inputs.synergyExtrapolation, ...
        inputs.emgDataColumnNames, ...
        inputs.emgData, ...
        inputs.muscleNames), ...
        inputs);
end
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end

function inputs = getInputs(tree)
inputs = parseMtpNcpSharedInputs(tree);
dataDirectory = getFieldByNameOrError(tree, 'data_directory').Text;
inputs = parseEmgData(tree, inputs, dataDirectory);
inputs.tasks = getTasks(tree);
if strcmpi(getTextFromField(getFieldByNameOrAlternate( ...
        getFieldByNameOrError(tree, 'MTPSynergyExtrapolation'), ...
        'is_enabled', 'false')), 'true')
    inputs.synergyExtrapolation = getSynergyExtrapolationParameters(tree, ...
        inputs.model, inputs);
    inputs.synergyExtrapolation = getTrialIndexes( ...
        inputs.synergyExtrapolation, size(inputs.emgData, 1), inputs.prefixes);
end
inputs = reorderPreprocessedDataByMuscleNames(inputs, inputs.muscleNames);
if ~isfield(inputs, 'emgSplines')
    inputs.emgSplines = makeEmgSplines(inputs.emgTime, ...
        inputs.emgDataExpanded);
end
end

function inputs = parseEmgData(tree, inputs, dataDirectory)
emgDataFileNames = findFileListFromPrefixList( ...
    fullfile(dataDirectory, "EMGData"), inputs.prefixes);
collectedEmgGroupNames = parseSpaceSeparatedList(tree, 'collected_emg_channel_muscle_groups');
[inputs.fullEmgData, inputs.emgDataColumnNames] = parseMtpStandard(emgDataFileNames);
[~, collectedEmgGroupNamesMembers] = intersect(inputs.emgDataColumnNames, collectedEmgGroupNames);
inputs.emgData = inputs.fullEmgData(:, collectedEmgGroupNamesMembers, :);
inputs.emgDataColumnNames = inputs.emgDataColumnNames(collectedEmgGroupNamesMembers);
firstEmgDataExpanded = expandEmgDatas(inputs.model, squeeze(inputs.emgData(1, :, :)), collectedEmgGroupNames, inputs.muscleNames);
inputs.emgDataExpanded = zeros(size(inputs.emgData, 1), size(firstEmgDataExpanded, 1), size(firstEmgDataExpanded, 2));
inputs.emgDataExpanded(1, :, :) = firstEmgDataExpanded;
for i = 2 : size(inputs.emgData, 1)
    inputs.emgDataExpanded(i, :, :) = ...
        expandEmgDatas(inputs.model, squeeze(inputs.emgData(i, :, :)), collectedEmgGroupNames, inputs.muscleNames);
end
inputs.emgTime = parseTimeColumn(findFileListFromPrefixList(...
    fullfile(dataDirectory, "EMGData"), inputs.prefixes));
inputs.numPaddingFrames = (size(inputs.emgData, 3) - 101) / 2;
end

% (struct, string, struct) -> (struct)
function output = getTasks(tree)
tasks = getFieldByNameOrError(tree, 'MTPTaskList');
counter = 1;
mtpTasks = orderByIndex(tasks.MTPTask);
for i=1:length(mtpTasks)
    if(length(mtpTasks) == 1)
        task = mtpTasks;
    else
        task = mtpTasks{i};
    end
    if(strcmp(task.is_enabled.Text, "true"))
        output{counter} = getTask(task);
        counter = counter + 1;
    end
end
end

% (integer, struct, string, struct) -> (struct)
function output = getTask(tree)
output.muscleSpecificElectromechanicalDelays = ...
    parseElementBoolean(tree, "muscle_specific_electromechanical_delays");
output.isIncluded = ones(1, 7);
output.isIncluded(1) = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, ...
    "optimize_electromechanical_delays", true));
output.isIncluded(2) = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, ...
    "optimize_activation_time_constants", true));
output.isIncluded(3) = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, ...
    "optimize_activation_nonlinearity_constants", true));
output.isIncluded(4) = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, ...
    "optimize_emg_scale_factors", true));
output.isIncluded(5) = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, ...
    "optimize_optimal_fiber_lengths", true));
output.isIncluded(6) = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, ...
    "optimize_tendon_slack_lengths", true));
output.costTerms = parseRcnlCostTermSet(tree.RCNLCostTermSet.RCNLCostTerm);
end

% (struct) -> (struct)
function params = getParams(tree)
params = struct();
maxIterations = getFieldByName(tree, 'max_iterations');
if(isstruct(maxIterations))
    params.maxIterations = str2double(maxIterations.Text);
end
maxFunctionEvaluations = getFieldByName(tree, 'max_function_evaluations');
if(isstruct(maxFunctionEvaluations))
    params.maxFunctionEvaluations = str2double( ...
        maxFunctionEvaluations.Text);
end
stepTolerance = getFieldByName(tree, 'step_tolerance');
if(isstruct(stepTolerance))
    params.stepTolerance = str2double( ...
        stepTolerance.Text);
end
performMuscleTendonLengthInitialization = getFieldByNameOrError(tree, ...
    'MuscleTendonLengthInitialization').is_enabled;
if(performMuscleTendonLengthInitialization.Text == "true")
    params.performMuscleTendonLengthInitialization = 1;
else
    params.performMuscleTendonLengthInitialization = 0;
end
end

function synergyExtrapolation = ...
    getSynergyExtrapolationParameters(tree, model, inputs)
groupNames = parseSpaceSeparatedList(tree, ...
    'missing_emg_channel_muscle_groups');
synergyExtrapolation.missingEmgChannelGroups = groupNamesToGroups( ...
    groupNames, model);
synergyExtrapolationTree = getFieldByNameOrError(tree, 'MTPSynergyExtrapolation');
synergyExtrapolation.matrixFactorizationMethod = ...
    getFieldByName(synergyExtrapolationTree, 'matrix_factorization_method').Text;
synergyExtrapolation.numberOfSynergies = ...
    str2double(getFieldByName(synergyExtrapolationTree, 'number_of_synergies').Text);
synergyExtrapolation.synergyExtrapolationCategorization = ...
    getFieldByName(synergyExtrapolationTree, 'synergy_extrapolation_categorization').Text;
synergyExtrapolation.residualCategorization = ...
    getFieldByName(synergyExtrapolationTree, 'residual_categorization').Text;
synergyExtrapolation.taskNames = inputs.prefixes;
synergyExtrapolation.costTerms = parseRcnlCostTermSet(...
    synergyExtrapolationTree.RCNLCostTermSet.RCNLCostTerm);
end

function inputs = getSynergyExtrapolationInputs(model, ...
    synergyExtrapolation, emgDataColumnNames, emgData, muscleNames)
model = Model(model);
groupToName = getMuscleNameByGroupStruct(model, ...
    emgDataColumnNames);
for i = 1 : length(fieldnames(groupToName))
    musclesInGroup = groupToName.(emgDataColumnNames(i));
    for j = 1 : length(musclesInGroup)
        synergyExtrapolation.currentEmgChannelGroups{i}(1, j) = ...
            find(strcmp(muscleNames, musclesInGroup(j)));
    end
end
[inputs.synergyWeights, inputs.numberOfExtrapolationWeights, ...
    inputs.numberOfResidualWeights] = ...
    getSynergyWeights(synergyExtrapolation, ...
    size(emgData, 1), ...
    size(synergyExtrapolation.currentEmgChannelGroups, 2), ...
    size(synergyExtrapolation.missingEmgChannelGroups, 2));
[inputs.extrapolationCommands, inputs.residualCommands] = ...
    getSynergyCommands(emgData, ...
    synergyExtrapolation.numberOfSynergies, ...
    synergyExtrapolation.matrixFactorizationMethod, ...
    synergyExtrapolation.synergyCategorizationOfTrials, ...
    synergyExtrapolation.residualCategorizationOfTrials);
inputs.synergyExtrapolation = synergyExtrapolation;
end
