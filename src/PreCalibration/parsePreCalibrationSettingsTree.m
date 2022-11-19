% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Muscle Tendon Personalization Settings XML file.
%
% (struct) -> (string, struct, struct)
% returns the input values for Precalibration

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function [inputs] = parsePreCalibrationSettingsTree(....
    settingsTree)
inputs = getInputs(settingsTree);
inputs = getModelInputs(inputs);
inputs = getMuscleVolume(inputs);
end

function inputs = getInputs(tree)
import org.opensim.modeling.Storage
inputDirectory = getFieldByName(tree, 'input_directory').Text;
passiveInputDirectory = getFieldByName(tree, 'passive_data_input_directory').Text;
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
prefixes = getPrefixes(tree, inputDirectory, 'trial_prefixes');
passivePrefixes = getPrefixes(tree, passiveInputDirectory, 'passive_trial_prefixes');
passiveJointMomentFileNames = findFileListFromPrefixList(fullfile( ...
    passiveInputDirectory, "IDData"), passivePrefixes);
inputs.coordinates = getStorageColumnNames(Storage( ...
    passiveJointMomentFileNames(1)));
inputs.passiveData.experimentalMoments = parseMtpStandard(passiveJointMomentFileNames);
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputDirectory, "MAData"), prefixes);
inputs.gaitData.muscleTendonLength = parseFileFromDirectories(directories, ...
    "Length.sto");
inputs.gaitData.momentArms = parseMomentArms(directories, inputs.model);
passiveDirectories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    passiveInputDirectory, "MAData"), passivePrefixes);
inputs.passiveData.muscleTendonLength = parseFileFromDirectories(passiveDirectories, ...
    "Length.sto");
inputs.passiveData.momentArms = parseMomentArms(passiveDirectories, inputs.model);
inputs.numPaddingFrames = (size(inputs.passiveData.experimentalMoments, 3) - 101) / 2;
inputs = reduceDataSize(inputs, inputs.numPaddingFrames);
inputs.tasks = getTask(tree);
optimizeIsometricMaxForce = getFieldByName(tree, ...
    'optimize_isometric_max_force').Text;
if(optimizeIsometricMaxForce == "true"); inputs.optimizeIsometricMaxForce = 1;
else; inputs.optimizeIsometricMaxForce = 0; end
inputs = getCostFunctionTerms(getFieldByNameOrError(tree, ...
    'PreCalibrationCostFunctionTerms'), inputs);
maximumMuscleStress = getFieldByName(tree, 'maximum_muscle_stress');
if(isstruct(maximumMuscleStress))
    inputs.maximumMuscleStress = str2double(maximumMuscleStress.Text);
end
maxNormalizedMuscleFiberLength = getFieldByName(tree, ...
    'max_normalized_muscle_fiber_length');
if(isstruct(maxNormalizedMuscleFiberLength))
    inputs.maxNormalizedMuscleFiberLength = ...
    str2double(maxNormalizedMuscleFiberLength.Text);
end
minNormalizedMuscleFiberLength = getFieldByName(tree, ...
    'min_normalized_muscle_fiber_length');
if(isstruct(minNormalizedMuscleFiberLength))
    inputs.minNormalizedMuscleFiberLength = ...
        str2double(minNormalizedMuscleFiberLength.Text);
end
inputs.normalizedFiberLengthPairs = getPairs(getFieldByNameOrError(tree, ...
    'PairedNormalizedMuscleFiberLengths'), inputs.model);
inputs = getNormalizedFiberLengthSettings(inputs);
end

% (struct) -> (Array of string)
function prefixes = getPrefixes(tree, inputDirectory, fieldName)
prefixField = getFieldByName(tree, fieldName);
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

% (integer, struct, string, struct) -> (struct)
function output = getTask(tree)
task = getFieldByNameOrError(tree, 'PreCalibrationSettings');
items = "optimize_maximum_muscle_stress";
output.maximumMuscleStressIsIncluded = strcmp(task.(items).Text, 'true');
end

function inputs = getCostFunctionTerms(tree, inputs)
inputs.costWeight = [];
inputs.errorCenters = [];
inputs.maxAllowableErrors = [];
individualMusclesTree = getFieldByNameOrError(tree, "IndividualMuscles");
pairedMusclesTree = getFieldByNameOrError(tree, "PairedMuscles");
individualMuscleTerms = ["PassiveJointMoments", ...
    "OptimalMuscleFiberLength", "TendonSlackLength", ...
    "MinimumNormalizedMuscleFiberLength", ...
    "MaximumNormalizedMuscleFiberLength", "MaximumMuscleStress", ...
    "PassiveMuscleForces", "MaxIsometricMuscleForce"];
for i=1:length(individualMuscleTerms)
    inputs = addCostFunctionTerms(getFieldByNameOrError(...
        individualMusclesTree, individualMuscleTerms(i)), inputs);
end
pairedMuscleTerms = ["NormalizedMuscleFiberLength", ...
    "MaximumNormalizedMuscleFiberLength"];
for i=1:length(pairedMuscleTerms)
    inputs = addCostFunctionTerms(getFieldByNameOrError(pairedMusclesTree, ...
        pairedMuscleTerms(i)), inputs);
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
inputs.passiveData.experimentalMoments = inputs.passiveData.experimentalMoments(:, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
inputs.gaitData.muscleTendonLength = inputs.gaitData.muscleTendonLength(:, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
inputs.gaitData.momentArms = inputs.gaitData.momentArms(:, :, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
inputs.passiveData.muscleTendonLength = inputs.passiveData.muscleTendonLength(:, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
inputs.passiveData.momentArms = inputs.passiveData.momentArms(:, :, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
end

function inputs = getMuscleVolume(inputs)

inputs.muscleVolume = (inputs.maxIsometricForce / ...
    inputs.maximumMuscleStress) .* inputs.optimalFiberLength;
end

function pairs = getPairs(tree, model)
pairElements = getFieldByName(tree, 'musclepairs');
activationGroupNames = string([]);
if isstruct(pairElements)
    activationGroupNames(end+1) = pairElements.Text;
elseif iscell(pairElements)
    for i=1:length(pairElements)
        activationGroupNames(end+1) = pairElements{i}.Text;
    end
else
    pairs = {};
    return
end
pairs = groupNamesToPairs(activationGroupNames, model);
end

function pairs = groupNamesToPairs(groupNames, model)
pairs = {};
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
    pairs{end + 1} = group;
end
end

function inputs = getNormalizedFiberLengthSettings(inputs)
inputs.numMusclePairs = numel(inputs.normalizedFiberLengthPairs);
numMuscles = getNumEnabledMuscles(inputs.model);
for i = 1 : inputs.numMusclePairs
for j = 1 : numel(inputs.normalizedFiberLengthPairs{i})
    inputs.groupedMaxNormalizedFiberLength(...
        inputs.normalizedFiberLengthPairs{i}(j)) = i;
end
end
inputs.numMusclesIndividual = 0;
for i = 1 :numMuscles
if isempty(find([inputs.normalizedFiberLengthPairs{:}] == i))
    inputs.groupedMaxNormalizedFiberLength(i) = inputs.numMusclePairs + ...
        inputs.numMusclesIndividual + 1;
    inputs.numMusclesIndividual = inputs.numMusclesIndividual + 1;
end
end
end

function inputs = getModelInputs(inputs)
inputs.numMuscles = getNumEnabledMuscles(inputs.model);
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