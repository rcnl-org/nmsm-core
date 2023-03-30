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
inputs = parseMtpNcpSharedInputs(tree);
inputs = getPassiveData(getFieldByNameOrError(tree, "MuscleTendonLengthInitialization"), inputs);
inputs = getTask(tree, inputs);

inputs = getNormalizedFiberLengthSettings(tree, inputs);
inputs = reorderPreprocessedDataByMuscleNames(inputs, inputs.muscleNames);
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
        inputs.coordinateNames = ...
            getStorageColumnNames(Storage(passiveJointMomentFileNames(1)));
        inputs.passiveData.inverseDynamicsMoments = ...
            parseMtpStandard(passiveJointMomentFileNames);
        passiveDirectories = ...
            findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
            passiveInputDirectory, "MAData"), inputs.passivePrefixes);
        [inputs.passiveMuscleTendonLength, ...
        inputs.passiveMuscleTendonLengthColumnNames] = ...
            parseFileFromDirectories(passiveDirectories, "Length.sto");
        if ~(length(inputs.passiveMuscleTendonLengthColumnNames) == length(inputs.muscleNames) && ...
            all(inputs.passiveMuscleTendonLengthColumnNames == inputs.muscleNames))
            throw(MException('', 'Muscle names in passive data do not match muscle names from coordinates.'))
        end
        inputs.passiveMomentsArms = ...
            parseMomentArms(passiveDirectories, inputs.model);
        inputs.passiveMomentDataExists = 1;
    end
end
end

% (integer, struct, string, struct) -> (struct)
function inputs = getTask(tree, inputs)
inputs.maximumMuscleStressIsIncluded = strcmp( ...
    getFieldByNameOrError( ...
        tree, ...
        'optimize_maximum_muscle_stress' ...
        ).Text, ...
    'true');

optimizeIsometricMaxForce = getFieldByName(tree, ...
    'optimize_isometric_max_force').Text;
inputs.optimizeIsometricMaxForce = 0;
if(optimizeIsometricMaxForce == "true")
    inputs.optimizeIsometricMaxForce = 1;
end
inputs = getCostFunctionTerms(getFieldByNameOrError(tree, ...
    'MuscleTendonLengthInitializationCostFunctionTerms'), inputs);
maximumMuscleStress = getFieldByName(tree, 'maximum_muscle_stress');
if(isstruct(maximumMuscleStress))
    inputs.maximumMuscleStress = str2double(maximumMuscleStress.Text);
else
    inputs.maximumMuscleStress = 610e3;
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

function inputs = getMuscleVolume(inputs)

inputs.muscleVolume = (inputs.maxIsometricForce / ...
    inputs.maximumMuscleStress) .* inputs.optimalFiberLength;
end

function inputs = getNormalizedFiberLengthSettings(tree, inputs)
normalizedFiberLengthGroupNames = parseSpaceSeparatedList(tree, ...
    "normalized_fiber_length_muscle_groups");
inputs.normalizedFiberLengthGroups = groupNamesToGroups( ...
    normalizedFiberLengthGroupNames, inputs.model);
inputs.numMuscleGroups = numel(inputs.normalizedFiberLengthGroups);
numMuscles = length(inputs.muscleNames);
for i = 1 : inputs.numMuscleGroups
    for j = 1 : numel(inputs.normalizedFiberLengthGroups{i})
        inputs.groupedMaxNormalizedFiberLength(...
            inputs.normalizedFiberLengthGroups{i}(j)) = i;
    end
end
inputs.numMusclesIndividual = 0;
for i = 1 : numMuscles
    if isempty(find([inputs.normalizedFiberLengthGroups{:}] == i, 1))
        inputs.groupedMaxNormalizedFiberLength(i) = inputs.numMuscleGroups + ...
            inputs.numMusclesIndividual + 1;
        inputs.numMusclesIndividual = inputs.numMusclesIndividual + 1;
    end
end
end

