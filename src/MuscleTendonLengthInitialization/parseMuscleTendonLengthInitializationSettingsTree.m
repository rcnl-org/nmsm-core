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
        'MuscleTendonLengthInitialization').is_enabled.Text, "true")
    inputs = getInputs(settingsTree);
    inputs = getMtpModelInputs(inputs);
    inputs = saveInitialLengthParameters(inputs);
    inputs = getMuscleVolume(inputs);
    inputs = rmfield(inputs, 'model');
else
    inputs = false;
end
end

function inputs = getInputs(tree)
inputs = parseMtpNcpSharedInputs(tree);
inputs = getPassiveData(getFieldByNameOrError(tree, 'MuscleTendonLengthInitialization'), inputs);
inputs = getTask(tree, inputs);

inputs = getNormalizedFiberLengthSettings(tree, inputs);
inputs = reorderPreprocessedDataByMuscleNames(inputs, inputs.muscleNames);
end

function inputs = getPassiveData(tree, inputs)
import org.opensim.modeling.Storage
passiveInputDirectory = getFieldByName(tree, 'passive_data_input_directory').Text;
inputs.passiveInputDirectory = passiveInputDirectory;
inputs.passiveMomentDataExists = 0;
if (~isempty(passiveInputDirectory))
    if isfolder(passiveInputDirectory)
        inputs.passivePrefixes = ...
            findPrefixes(tree, passiveInputDirectory, true);
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
            parseFileFromDirectories(passiveDirectories, "_Length.sto", ...
            Model(inputs.model));
        if ~(sum(ismember(inputs.muscleNames, ...
                inputs.passiveMuscleTendonLengthColumnNames)) == ...
                length(inputs.muscleNames))
            throw(MException('', 'Muscle names in passive data do not match muscle names from coordinates.'))
        end
        [inputs.passiveMomentArms, inputs.passiveMomentArmCoordinates] = ...
            parseMomentArms(passiveDirectories, inputs.model);
        includedIndices = ismember( ...
            inputs.passiveMuscleTendonLengthColumnNames, inputs.muscleNames);
        inputs.passiveMuscleTendonLengthColumnNames = inputs.passiveMuscleTendonLengthColumnNames(includedIndices);
        [~, ~, momentCoordinateIndices] = intersect(inputs.coordinateNames, ...
            inputs.passiveMomentArmCoordinates, 'stable');
        if isempty(momentCoordinateIndices)
            [~, ~, momentCoordinateIndices] = intersect(inputs.coordinateNames, ...
            strcat(inputs.passiveMomentArmCoordinates,"_moment"), 'stable');
        end
        inputs.passiveMomentArms = inputs.passiveMomentArms(:, momentCoordinateIndices, includedIndices, :);
        
        inputs.passiveMuscleTendonLength = inputs.passiveMuscleTendonLength(:, includedIndices, :);
        inputs.passiveMomentDataExists = 1;
    end
end
end

% (integer, struct, string, struct) -> (struct)
function inputs = getTask(tree, inputs)
inputs.maximumMuscleStressIsIncluded = strcmpi( ...
    getFieldByNameOrError( ...
        tree, ...
        'optimize_maximum_muscle_stress' ...
        ).Text, ...
    'true');

inputs.optimizeIsometricMaxForce = strcmpi(getTextFromField( ...
    getFieldByNameOrAlternate(tree, ...
    "update_maximum_isometric_force", "true")), "true");
inputs.optimizeIsometricMaxForce = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, "optimize_isometric_max_force", ...
    inputs.optimizeIsometricMaxForce));

inputs.useAbsoluteLengths = strcmpi( ...
    getTextFromField( ...
    getFieldByNameOrAlternate(tree, "optimize_absolute_length_changes", ...
    "false")), "true");

inputs.costTerms = getCostFunctionTerms(getFieldByNameOrError(tree, ...
    'MuscleTendonLengthInitialization'));
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

function costTerms = getCostFunctionTerms(tree)
costTerms = parseRcnlCostTermSet( ...
    tree.RCNLCostTermSet.RCNLCostTerm);
end

function inputs = getMuscleVolume(inputs)
inputs.muscleVolume = (inputs.maxIsometricForce / ...
    inputs.maximumMuscleStress) .* inputs.optimalFiberLength;
end

function inputs = getNormalizedFiberLengthSettings(tree, inputs)
normalizedFiberLengthGroupNames = parseSpaceSeparatedList(tree, ...
    'normalized_fiber_length_muscle_groups');
inputs.normalizedFiberLengthGroups = groupNamesToGroups( ...
    normalizedFiberLengthGroupNames, inputs.model);
inputs.numMuscleGroups = numel(inputs.normalizedFiberLengthGroups);
numMuscles = length(inputs.muscleNames);
lowestIndex = min(cell2mat(inputs.normalizedFiberLengthGroups));
for i = 1 : inputs.numMuscleGroups
    for j = 1 : numel(inputs.normalizedFiberLengthGroups{i})
        inputs.groupedMaxNormalizedFiberLength(...
            inputs.normalizedFiberLengthGroups{i}(j) ...
            - lowestIndex + 1) = i;
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

function inputs = saveInitialLengthParameters(inputs)
inputs.initialOptimalFiberLength = inputs.optimalFiberLength;
inputs.initialTendonSlackLength = inputs.tendonSlackLength;
end
