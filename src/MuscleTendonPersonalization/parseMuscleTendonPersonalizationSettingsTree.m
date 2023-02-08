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
inputs = getSynergyExtrapolationInputs(inputs);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end

function inputs = getInputs(tree)
import org.opensim.modeling.Storage
inputDirectory = parseInputDirectory(tree);
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
if(~isempty(inputDirectory))
    try
        inputs.model = fullfile(inputDirectory, modelFile);
    catch
        inputs.model = fullfile(pwd, inputDirectory, modelFile);
        inputDirectory = fullfile(pwd, inputDirectory);
    end
else
    inputs.model = fullfile(pwd, modelFile);
    inputDirectory = pwd;
end
inputs.prefixes = findPrefixes(tree, inputDirectory);
inverseDynamicsFileNames = findFileListFromPrefixList(fullfile( ...
    inputDirectory, "IDData"), inputs.prefixes);
inputs.coordinates = getStorageColumnNames(Storage( ...
    inverseDynamicsFileNames(1)));
inputs.experimentalMoments = parseMtpStandard(inverseDynamicsFileNames);
emgDataFileNames = findFileListFromPrefixList( ...
    fullfile(inputDirectory, "EMGData"), inputs.prefixes);
inputs.emgData = parseMtpStandard(emgDataFileNames);
inputs.emgDataExpanded = parseEmgWithExpansion(inputs.model, emgDataFileNames);
inputs.emgDataColumnNames = getStorageColumnNames(Storage( ...
    emgDataFileNames(1)));
inputs.emgTime = parseTimeColumn(findFileListFromPrefixList(...
    fullfile(inputDirectory, "EMGData"), inputs.prefixes));
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputDirectory, "MAData"), inputs.prefixes);
inputs.muscleTendonLength = parseFileFromDirectories(directories, ...
    "Length.sto");
inputs.muscleTendonVelocity = parseFileFromDirectories(directories, ...
    "Velocity.sto");
inputs.momentArms = parseMomentArms(directories, inputs.model);
inputs.numPaddingFrames = (size(inputs.emgData, 3) - 101) / 2;
inputs = reduceDataSize(inputs);
inputs.tasks = getTasks(tree);
inputs.activationGroups = findGroups(getFieldByNameOrError(tree, ...
    'GroupedActivationTimeConstants'), inputs.model);
inputs.normalizedFiberLengthGroups = findGroups(getFieldByNameOrError(tree, ...
    'GroupedNormalizedMuscleFiberLengths'), inputs.model);
inputs.synergyExtrapolation = getSynergyExtrapolationParameters(tree, ...
    inputs.model);
inputs.vMaxFactor = getVMaxFactor(tree);
inputs.synergyExtrapolation = getTrialIndexes( ...
    inputs.synergyExtrapolation, size(inputs.emgData, 1), inputs.prefixes);

if ~isfield(inputs, "emgSplines")
    inputs.emgSplines = makeEmgSplines(inputs.emgTime, inputs.emgDataExpanded);
end
end

% (struct, string, struct) -> (struct)
function output = getTasks(tree)
tasks = getFieldByNameOrError(tree, 'MuscleTendonPersonalizationTaskList');
counter = 1;
mtpTasks = orderByIndex(tasks.MuscleTendonPersonalizationTask);
for i=1:length(mtpTasks)
    if(length(mtpTasks) == 1)
        task = mtpTasks;
    else
        task = mtpTasks{i};
    end
    if(task.is_enabled.Text == 'true')
        output{counter} = getTask(task);
        counter = counter + 1;
    end
end
end

% (integer, struct, string, struct) -> (struct)
function output = getTask(tree)
items = ["optimize_electromechanical_delays", ...
    "optimize_activation_time_constants", ...
    "optimize_activation_nonlinearity_constants", ...
    "optimize_emg_scale_factors", "optimize_optimal_fiber_lengths", ...
    "optimize_tendon_slack_lengths", "perform_synergy_extrapolation"];
output.isIncluded = zeros(1,length(items));
for i=1:length(items)
    output.isIncluded(i) = strcmp(tree.(items(i)).Text, 'true');
end
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
    params.maxFunctionEvaluations = str2double(maxFunctionEvaluations.Text);
end
performMuscleTendonLengthInitialization = getFieldByNameOrError(tree, ...
    'MuscleTendonLengthInitialization').is_enabled;
if(performMuscleTendonLengthInitialization.Text == "true")
    params.performMuscleTendonLengthInitialization = 1;
else
    params.performMuscleTendonLengthInitialization = 0;
end
params = getCostFunctionTerms(getFieldByNameOrError(tree, ...
    'MuscleTendonCostFunctionTerms'), params);
end

function params = getCostFunctionTerms(tree, params)
individualMusclesTree = getFieldByNameOrError(tree, "IndividualMuscles");
groupedMusclesTree = getFieldByNameOrError(tree, "GroupedMuscles");
synergyExtrapolationSettingsTree = getFieldByNameOrError(tree, ...
    "SynergyExtrapolationSettings");
individualMuscleTerms = ["InverseDynamicJointMoments", ...
    "ActivationTimeConstant", "ActivationNonlinearityConstant", ...
    "OptimalMuscleFiberLength", "TendonSlackLength", "EmgScalingFactors", ...
    "NormalizedMuscleFiberLength", "PassiveMuscleForces"];
individualMuscleCostTermNames = ["momentTracking", ...
    "activationTimeConstantDeviation", "activationNonlinearityDeviation", ...
    "optimalFiberLengthDeviation", "tendonSlackLengthDeviation", ...
    "emgScaleFactorDeviation", "normalizedFiberLengthDeviation", ...
    "passiveForce"];
for i=1:length(individualMuscleTerms)
    params = addCostFunctionTerms(getFieldByNameOrError(...
        individualMusclesTree, individualMuscleTerms(i)), ...
        individualMuscleCostTermNames(i), params);
end
groupedMuscleTerms = ["NormalizedMuscleFiberLength", ...
    "EmgScalingFactors", "ElectromechanicalDelay"];
groupedMuscleCostTermNames = ["normalizedFiberLengthGroupedSimiliarity", ...
    "emgScaleFactorGroupedSimilarity", ...
    "electromechanicalDelayGroupedSimilarity"];
for i=1:length(groupedMuscleTerms)
    params = addCostFunctionTerms(getFieldByNameOrError(groupedMusclesTree, ...
        groupedMuscleTerms(i)), groupedMuscleCostTermNames(i), params);
end
synergyExtrapolationSettingsTerms = ["MeasuredInverseDynamicJointMoments", ...
    "ExtrapolatedMuscleActivations", "ResidualMuscleActivations"];
synergyExtrapolationCostTermNames = ["measuredMomentTracking", ...
    "muscleActivationsFromSynergy", "muscleActivationsFromResiduals"];
for i=1:length(synergyExtrapolationSettingsTerms)
    params = addCostFunctionTerms(getFieldByNameOrError(...
        synergyExtrapolationSettingsTree, ...
        synergyExtrapolationSettingsTerms(i)), ...
        synergyExtrapolationCostTermNames(i), params);
end
end

function params = addCostFunctionTerms(tree, costTermName, params)
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true")
    params.(strcat(costTermName, "CostWeight")) = 1;
else
    params.(strcat(costTermName, "CostWeight")) = 0;
end
params.(strcat(costTermName, "MaximumAllowableError")) = ...
    str2double(getFieldByNameOrError(tree, "max_allowable_error").Text);
errorCenter = getFieldByName(tree, "error_center");
if ~isstruct(errorCenter)
    params.(strcat(costTermName, "ErrorCenter")) = 0;
else
    params.(strcat(costTermName, "ErrorCenter")) = str2double(errorCenter.Text);
end
end

function inputs = reduceDataSize(inputs)
numPaddingFrames = (size(inputs.experimentalMoments, 3) - 101) / 2;
inputs.experimentalMoments = inputs.experimentalMoments(:, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
numPaddingFrames = (size(inputs.muscleTendonLength, 3) - 101) / 2;
inputs.muscleTendonLength = inputs.muscleTendonLength(:, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
numPaddingFrames = (size(inputs.muscleTendonVelocity, 3) - 101) / 2;
inputs.muscleTendonVelocity = inputs.muscleTendonVelocity(:, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
numPaddingFrames = (size(inputs.momentArms, 4) - 101) / 2;
inputs.momentArms = inputs.momentArms(:, :, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
end

function vMaxFactor = getVMaxFactor(tree)
vMaxFactor = getFieldByName(tree, 'v_max_factor');
if(isstruct(vMaxFactor))
    vMaxFactor = str2double(vMaxFactor.Text);
else
    vMaxFactor = 10;
end
end

function synergyExtrapolation = ...
    getSynergyExtrapolationParameters(tree, model)
synergyExtrapolation.missingEmgChannelGroups = ...
    findGroups(getFieldByNameOrError(tree, 'GroupedMissingEmgChannels'), ...
    model);
synergyExtrapolation.matrixFactorizationMethod = ...
    getFieldByName(tree, 'matrix_factorization_method');
synergyExtrapolation.matrixFactorizationMethod = ...
    synergyExtrapolation.matrixFactorizationMethod.Text;
synergyExtrapolation.numberOfSynergies = ...
    getFieldByName(tree, 'number_of_synergies');
synergyExtrapolation.numberOfSynergies = ...
    str2double(synergyExtrapolation.numberOfSynergies.Text);
synergyExtrapolation.synergyExtrapolationCategorization = ...
    getFieldByName(tree, 'synergy_extrapolation_categorization');
synergyExtrapolation.synergyExtrapolationCategorization = ...
    synergyExtrapolation.synergyExtrapolationCategorization.Text;
synergyExtrapolation.residualCategorization = ...
    getFieldByName(tree, 'residual_categorization');
synergyExtrapolation.residualCategorization = ...
    synergyExtrapolation.residualCategorization.Text;
synergyExtrapolation.taskNames = getFieldByName(tree, 'task_prefixes');
synergyExtrapolation.taskNames = ...
    strsplit(synergyExtrapolation.taskNames.Text, ' ');
end

function inputs = getSynergyExtrapolationInputs(inputs)
model = Model(inputs.model);
columnNames = getEnabledMusclesInOrder(model);
groupToName = getMuscleNameByGroupStruct(model, ...
    inputs.emgDataColumnNames);
for i = 1 : length(fieldnames(groupToName))
    musclesInGroup = groupToName.(inputs.emgDataColumnNames(i));
    for j = 1 : length(musclesInGroup)
        inputs.synergyExtrapolation.currentEmgChannelGroups{i}(1, j) = ...
            find(strcmp(columnNames, musclesInGroup(j)));
    end
end
[inputs.synergyWeights, inputs.numberOfExtrapolationWeights, ...
    inputs.numberOfResidualWeights] = ...
    getSynergyWeights(inputs.synergyExtrapolation, ...
    size(inputs.emgData, 1), ...
    size(inputs.synergyExtrapolation.currentEmgChannelGroups, 2), ...
    size(inputs.synergyExtrapolation.missingEmgChannelGroups, 2));
[inputs.extrapolationCommands, inputs.residualCommands] = ...
    getSynergyCommands(inputs.emgData, ...
    inputs.synergyExtrapolation.numberOfSynergies, ...
    inputs.synergyExtrapolation.matrixFactorizationMethod, ...
    inputs.synergyExtrapolation.synergyCategorizationOfTrials, ...
    inputs.synergyExtrapolation.residualCategorizationOfTrials);
end
