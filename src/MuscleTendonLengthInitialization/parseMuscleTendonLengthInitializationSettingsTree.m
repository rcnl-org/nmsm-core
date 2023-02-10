% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Muscle Tendon Personalization Settings XML file.
%
% (struct) -> (string, struct, struct)
% returns the input values for muscle tendon length initialization

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

function inputs = parseMuscleTendonLengthInitializationSettingsTree( ...
    settingsTree)
if strcmp(getFieldByNameOrError(settingsTree, ...
        "MuscleTendonLengthInitialization").is_enabled.Text, "true")
    inputs = getInputs(settingsTree);
    inputs = getMtpModelInputs(inputs);
    inputs = getMuscleVolume(inputs);
else
    inputs = false;
end
end

function inputs = getInputs(tree)
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
inputs = getPassiveData(getFieldByNameOrError(tree, "MuscleTendonLengthInitialization"), inputs);
prefixes = findPrefixes(tree, inputDirectory);
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputDirectory, "MAData"), prefixes);
inputs.gaitData.muscleTendonLength = parseFileFromDirectories(directories, ...
    "Length.sto");
inputs.gaitData.momentArms = parseMomentArms(directories, inputs.model);
inputs.numPaddingFrames = (size(inputs.gaitData.muscleTendonLength, 3) - 101) / 2;
inputs = reduceDataSize(inputs, inputs.numPaddingFrames, ...
    inputs.passiveMomentDataExists);
inputs.tasks = getTask(tree);
optimizeIsometricMaxForce = getFieldByName(tree, ...
    'optimize_isometric_max_force').Text;
if(optimizeIsometricMaxForce == "true"); inputs.optimizeIsometricMaxForce = 1;
else; inputs.optimizeIsometricMaxForce = 0; end
inputs = getCostFunctionTerms(getFieldByNameOrError(tree, ...
    'MuscleTendonLengthInitializationCostFunctionTerms'), inputs);
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
muscleGroupTree = getFieldByNameOrError(tree, 'GroupedMuscles');
groupNames = parseSpaceSeparatedList(muscleGroupTree, ...
    "normalized_muscle_fiber_lengths");
inputs.normalizedFiberLengthGroups = groupNamesToGroups( ...
    groupNames, inputs.model);
inputs = getNormalizedFiberLengthSettings(inputs);
end

function inputs = getPassiveData(tree, inputs)
import org.opensim.modeling.Storage
passiveInputDirectory = getFieldByName(tree, 'passive_data_input_directory').Text;
inputs.passiveMomentDataExists = 0;
if (~isempty(passiveInputDirectory))
    if isfolder(passiveInputDirectory)
        inputs.passivePrefixes = ...
            findPrefixes(tree, passiveInputDirectory);
        passiveJointMomentFileNames = ...
            findFileListFromPrefixList(fullfile(...
            passiveInputDirectory, "IDData"), inputs.passivePrefixes);
        inputs.coordinates = ...
            getStorageColumnNames(Storage(passiveJointMomentFileNames(1)));
        inputs.passiveData.experimentalMoments = ...
            parseMtpStandard(passiveJointMomentFileNames);
        passiveDirectories = ...
            findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
            passiveInputDirectory, "MAData"), inputs.passivePrefixes);
        inputs.passiveData.muscleTendonLength = ...
            parseFileFromDirectories(passiveDirectories, "Length.sto");
        inputs.passiveData.momentArms = ...
            parseMomentArms(passiveDirectories, inputs.model);
        inputs.passiveMomentDataExists = 1;
    end
end
end

% (integer, struct, string, struct) -> (struct)
function output = getTask(tree)
task = getFieldByNameOrError(tree, 'MuscleTendonLengthInitialization');
items = "optimize_maximum_muscle_stress";
output.maximumMuscleStressIsIncluded = strcmp(task.(items).Text, 'true');
end

function inputs = getCostFunctionTerms(tree, inputs)
individualMusclesTree = getFieldByNameOrError(tree, "IndividualMuscles");
groupedMusclesTree = getFieldByNameOrError(tree, "GroupedMuscles");
individualMuscleTerms = ["PassiveJointMoments", ...
    "OptimalMuscleFiberLength", "TendonSlackLength", ...
    "MinimumNormalizedMuscleFiberLength", ...
    "MaximumNormalizedMuscleFiberLength", "MaximumMuscleStress", ...
    "PassiveMuscleForces"];
individualMuscleCostTermNames = ["passiveMomentTracking", ...
    "optimalFiberLengthScaleFactorDeviation", ...
    "tendonSlackLengthScaleFactorDeviation", ...
    "minimumNormalizedFiberLengthDeviation", ...
    "maximumNormalizedFiberLengthDeviation", ...
    "maximumMuscleStressPenalty", "maximumPassiveForcePenalty"];
for i=1:length(individualMuscleTerms)
    inputs = addCostFunctionTerms(getFieldByNameOrError(...
        individualMusclesTree, individualMuscleTerms(i)), ...
        individualMuscleCostTermNames(i), inputs);
end
groupedMuscleTerms = ["NormalizedMuscleFiberLength", ...
    "MaximumNormalizedMuscleFiberLength"];
groupedMuscleCostTermNames = ["normalizedFiberLengthMeanSimilarity", ...
    "maximumNormalizedFiberLengthSimilarity"];
for i=1:length(groupedMuscleTerms)
    inputs = addCostFunctionTerms(getFieldByNameOrError(groupedMusclesTree, ...
        groupedMuscleTerms(i)), groupedMuscleCostTermNames(i), inputs);
end
end

function inputs = addCostFunctionTerms(tree, costTermName, inputs)
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true")
    eval(strcat("inputs.params.", costTermName, "CostWeight = 1;"));
else
    eval(strcat("inputs.params.", costTermName, "CostWeight = 0;"));
end
maxError = getFieldByNameOrError(tree, "max_allowable_error").Text;
eval(strcat("inputs.params.", costTermName, ...
    "MaximumAllowableError = ", maxError, ';'));
errorCenter = getFieldByName(tree, "error_center");
if ~isstruct(errorCenter)
    eval(strcat("inputs.params.", costTermName, "ErrorCenter = 0;"));
else
    eval(strcat("inputs.params.", costTermName, "ErrorCenter = ", ...
        errorCenter.Text, ';'));  
end
end

function inputs = reduceDataSize(inputs, numPaddingFrames, ...
    passiveMomentDataExists)

if passiveMomentDataExists
        inputs.passiveData.experimentalMoments = ...
            inputs.passiveData.experimentalMoments(:, :, ...
            numPaddingFrames + 1:end-numPaddingFrames);
        inputs.passiveData.muscleTendonLength = ...
            inputs.passiveData.muscleTendonLength(:, :, ...
            numPaddingFrames + 1:end-numPaddingFrames);
        inputs.passiveData.momentArms = ...
            inputs.passiveData.momentArms(:, :, :, ...
            numPaddingFrames + 1:end-numPaddingFrames);
end
inputs.gaitData.muscleTendonLength = inputs.gaitData.muscleTendonLength(:, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
inputs.gaitData.momentArms = inputs.gaitData.momentArms(:, :, :, ...
    numPaddingFrames + 1:end-numPaddingFrames);
end

function inputs = getMuscleVolume(inputs)

inputs.muscleVolume = (inputs.maxIsometricForce / ...
    inputs.maximumMuscleStress) .* inputs.optimalFiberLength;
end

function inputs = getNormalizedFiberLengthSettings(inputs)
inputs.numMuscleGroups = numel(inputs.normalizedFiberLengthGroups);
numMuscles = getNumEnabledMuscles(inputs.model);
for i = 1 : inputs.numMuscleGroups
for j = 1 : numel(inputs.normalizedFiberLengthGroups{i})
    inputs.groupedMaxNormalizedFiberLength(...
        inputs.normalizedFiberLengthGroups{i}(j)) = i;
end
end
inputs.numMusclesIndividual = 0;
for i = 1 :numMuscles
if isempty(find([inputs.normalizedFiberLengthGroups{:}] == i))
    inputs.groupedMaxNormalizedFiberLength(i) = inputs.numMuscleGroups + ...
        inputs.numMusclesIndividual + 1;
    inputs.numMusclesIndividual = inputs.numMusclesIndividual + 1;
end
end
end

