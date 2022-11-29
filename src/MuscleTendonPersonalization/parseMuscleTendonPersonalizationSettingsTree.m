% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Joint Model Personalization Settings XML file.
%
% (struct) -> (string, struct, struct)
% returns the input values for Joint Model Personalization

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
    parseMuscleTendonPersonalizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
inputs = getModelInputs(inputs);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end

function inputs = getInputs(tree)
import org.opensim.modeling.Storage
inputDirectory = getFieldByName(tree, 'input_directory').Text;
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
prefixes = getPrefixes(tree, inputDirectory);
inverseDynamicsFileNames = findFileListFromPrefixList(fullfile( ...
    inputDirectory, "IDData"), prefixes);
inputs.coordinates = getStorageColumnNames(Storage( ...
    inverseDynamicsFileNames(1)));
inputs.experimentalMoments = parseMtpStandard(inverseDynamicsFileNames);
inputs.emgData = parseEmgWithExpansion(findFileListFromPrefixList( ...
    fullfile(inputDirectory, "EMGData"), prefixes));
inputs.emgTime = parseTimeColumn(findFileListFromPrefixList(...
    fullfile(inputDirectory, "EMGData"), prefixes));
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputDirectory, "MAData"), prefixes);
inputs.muscleTendonLength = parseFileFromDirectories(directories, ...
    "Length.sto");
inputs.muscleTendonVelocity = parseFileFromDirectories(directories, ...
    "Velocity.sto");
inputs.momentArms = parseMomentArms(directories, inputs.model);
inputs.numPaddingFrames = (size(inputs.experimentalMoments, 3) - 101) / 2;
inputs = reduceDataSize(inputs, inputs.numPaddingFrames);
inputs.tasks = getTasks(tree);
inputs.activationGroups = getGroups(getFieldByNameOrError(tree, 'GroupedActivationTimeConstants'), inputs.model);
inputs.normalizedFiberLengthGroups = getGroups(getFieldByNameOrError(tree, 'GroupedNormalizedMuscleFiberLengths'), inputs.model);
inputs = getCostFunctionTerms(getFieldByNameOrError(tree, 'MuscleTendonCostFunctionTerms'), inputs);
inputs.vMaxFactor = getVMaxFactor(tree);
if ~isfield(inputs, "emgSplines")
    inputs.emgSplines = makeEmgSplines(inputs.emgTime, inputs.emgData);
end
end

% (struct) -> (Array of string)
function prefixes = getPrefixes(tree, inputDirectory)
prefixField = getFieldByName(tree, 'trial_prefixes');
if(length(prefixField.Text) > 0)
    prefixes = strsplit(prefixField.Text, ' ');
else
    files = dir(fullfile(inputDirectory, "IKData"));
    prefixes = string([]);
    for i=1:length(files)
        if(~files(i).isdir)
            prefixes(end+1) = files(i).name(1:end-4);
        end
    end
end
end

% (struct, string, struct) -> (struct)
function output = getTasks(tree)
tasks = getFieldByNameOrError(tree, 'MuscleTendonPersonalizationTaskList');
counter = 1;
for i=1:length(tasks.MuscleTendonPersonalizationTask)
    if(length(tasks.MuscleTendonPersonalizationTask) == 1)
        task = tasks.MuscleTendonPersonalizationTask;
    else
        task = tasks.MuscleTendonPersonalizationTask{i};
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
    "optimize_tendon_slack_lengths"];
output.isIncluded = zeros(1,length(items));
for i=1:length(items)
    output.isIncluded(i) = strcmp(tree.(items(i)).Text, 'true');
end
end

function groups = getGroups(tree, model)
groupElements = getFieldByName(tree, 'musclegroups');
activationGroupNames = string([]);
if isstruct(groupElements)
    activationGroupNames(end+1) = groupElements.Text;
elseif iscell(groupElements)
    for i=1:length(groupElements)
        activationGroupNames(end+1) = groupElements{i}.Text;
    end
else
    groups = {};
    return
end
groups = groupNamesToGroups(activationGroupNames, model);
end

function groups = groupNamesToGroups(groupNames, model)
groups = {};
model = Model(model);
for i=1:length(groupNames)
    group = [];
    for j=0:model.getForceSet().getGroup(groupNames(i)).getMembers().getSize()-1
        count = 1;
        for k=0:model.getForceSet().getMuscles().getSize()-1
            if strcmp(model.getForceSet().getMuscles().get(k).getName().toCharArray', model.getForceSet().getGroup(groupNames(i)).getMembers().get(j))
                break
            end
            if(model.getForceSet().getMuscles().get(k).get_appliesForce())
                count = count + 1;
            end
        end
        group(end+1) = count;
    end
    groups{end + 1} = group;
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
end

function inputs = getModelInputs(inputs)
inputs.optimalFiberLength = [];
inputs.tendonSlackLength = [];
inputs.pennationAngle = [];
inputs.maxIsometricForce = [];
model = Model(inputs.model);
for i = 0:model.getForceSet().getMuscles().getSize()-1
    if model.getForceSet().getMuscles().get(i).get_appliesForce()
        inputs.optimalFiberLength(end+1) = model.getForceSet(). ...
            getMuscles().get(i).getOptimalFiberLength();
        inputs.tendonSlackLength(end+1) = model.getForceSet(). ...
            getMuscles().get(i).getTendonSlackLength();
        inputs.pennationAngle(end+1) = model.getForceSet(). ...
            getMuscles().get(i). ...
            getPennationAngleAtOptimalFiberLength();
        inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
            getMuscles().get(i).getMaxIsometricForce();
    end
end
end

function inputs = getCostFunctionTerms(tree, inputs)
inputs.costWeight = [];
inputs.errorCenters = [];
inputs.maxAllowableErrors = [];
individualMusclesTree = getFieldByNameOrError(tree, "IndividualMuscles");
groupedMusclesTree = getFieldByNameOrError(tree, "GroupedMuscles");
individualMuscleTerms = ["InverseDynamicJointMoments", "ActivationTimeConstant", "ActivationNonlinearityConstant", "OptimalMuscleFiberLength", "TendonSlackLength", "EmgScalingFactors", "NormalizedMuscleFiberLength", "PassiveMuscleForces"];
for i=1:length(individualMuscleTerms)
    inputs = addCostFunctionTerms(getFieldByNameOrError(individualMusclesTree, individualMuscleTerms(i)), inputs);
end
groupedMuscleTerms = ["NormalizedMuscleFiberLength", "EmgScalingFactors", "ElectromechanicalDelay"];
for i=1:length(groupedMuscleTerms)
    inputs = addCostFunctionTerms(getFieldByNameOrError(groupedMusclesTree, groupedMuscleTerms(i)), inputs);
end
end

function inputs = addCostFunctionTerms(tree, inputs)
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true"); inputs.costWeight(end+1) = 1;
else; inputs.costWeight(end+1) = 0; end
maxError = getFieldByNameOrError(tree, "max_allowable_error").Text;
inputs.maxAllowableErrors(end+1) = str2double(maxError);
errorCenter = getFieldByName(tree, "error_center");
if ~isstruct(errorCenter)
    inputs.errorCenters(end+1) = 0;
else
inputs.errorCenters(end+1) = str2double(errorCenter.Text);
end
end

function inputs = reduceDataSize(inputs, numPaddingFrames)
inputs.experimentalMoments = inputs.experimentalMoments(:, :, numPaddingFrames + 1:end-numPaddingFrames);
inputs.muscleTendonLength = inputs.muscleTendonLength(:, :, numPaddingFrames + 1:end-numPaddingFrames);
inputs.muscleTendonVelocity = inputs.muscleTendonVelocity(:, :, numPaddingFrames + 1:end-numPaddingFrames);
inputs.momentArms = inputs.momentArms(:, :, :, numPaddingFrames + 1:end-numPaddingFrames);
end

function vMaxFactor = getVMaxFactor(tree)
vMaxFactor = getFieldByName(tree, 'v_max_factor');
if(isstruct(vMaxFactor))
    vMaxFactor = str2double(vMaxFactor.Text);
else
    vMaxFactor = 10;
end
end