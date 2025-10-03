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
inputs = rmfield(inputs, "model");
end

function inputs = getInputs(tree)
inputs = parseMtpNcpSharedInputs(tree);
inputs.synergyGroups = parseSynergyGroups(tree, inputs.model);
inputs = matchMuscleNamesFromCoordinatesAndSynergyGroups(inputs);
inputs = reorderPreprocessedDataByMuscleNames(inputs, inputs.muscleNames);
[inputs.maxIsometricForce, inputs.optimalFiberLength, ...
    inputs.tendonSlackLength, inputs.pennationAngle] = ...
    getMuscleInputs(inputs, inputs.muscleTendonColumnNames);
mtpResults = getFieldByName(tree, "mtp_results_directory");
if isstruct(mtpResults) && ~isempty(mtpResults.Text)
    inputs = loadMtpData(tree, inputs);
    [inputs.optimalFiberLengthScaleFactors, ...
        inputs.tendonSlackLengthScaleFactors, ...
        inputs.maxIsometricForce] = getMtpDataInputs(inputs);
else
    inputs.optimalFiberLengthScaleFactors = ...
        ones(1, length(inputs.muscleTendonColumnNames));
    inputs.tendonSlackLengthScaleFactors = ...
        ones(1, length(inputs.muscleTendonColumnNames));
end
end

function inputs = loadMtpData(tree, inputs)
mtpResultsDirectory = getFieldByNameOrError( ...
    tree, "mtp_results_directory").Text;
[inputs.mtpActivations, inputs.mtpActivationsColumnNames] = ...
    parseMtpStandard(findFileListFromPrefixList( ...
    fullfile(mtpResultsDirectory, "muscleActivations"), inputs.prefixes));
osimxFileName = getFieldByName(tree, "input_osimx_file");
% if ~isstruct(osimxFileName) || isempty(osimxFileName.Text)
%     throw(MException('', 'An input .osimx file is required if using data from MTP.'))
% end
inputs.mtpMuscleData = parseOsimxFile(osimxFileName.Text, inputs.model);
% Remove activations of muscles from coordinates not included
includedSubset = ismember(inputs.mtpActivationsColumnNames, ...
    inputs.muscleTendonColumnNames);
inputs.mtpActivationsColumnNames = ...
    inputs.mtpActivationsColumnNames(includedSubset);
inputs.mtpActivations = inputs.mtpActivations(:, includedSubset, :);

inputs.allow_negative_synergy_vector_weights = strcmpi(getTextFromField(...
    getFieldByNameOrAlternate(tree, ...
    'allow_negative_synergy_vector_weights', 'false')), 'true');
inputs.use_activation_saturation = strcmpi(getTextFromField(...
    getFieldByNameOrAlternate(tree, ...
    'use_activation_saturation','false')), 'true');
inputs.activation_saturation_sharpness = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, ...
    'activation_saturation_sharpness', '600')));
inputs.synergy_vector_normalization_method = string(getTextFromField(...
    getFieldByNameOrAlternate(tree, ...
    'synergy_vector_normalization_method', 'sum')));
inputs.synergy_vector_normalization_value = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, ...
    'synergy_vector_normalization_value', '1')));

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
params = struct();
params.activationGroupNames = parseSpaceSeparatedList(tree, ...
    'activation_muscle_groups');
params.activationGroups = groupNamesToGroups( ...
    params.activationGroupNames, model);
params.normalizedFiberLengthGroupNames = parseSpaceSeparatedList(tree, ...
    'normalized_fiber_length_muscle_groups');
params.normalizedFiberLengthGroups = groupNamesToGroups( ...
    params.normalizedFiberLengthGroupNames, model);
params.costTerms = parseRcnlCostTermSet( ...
    getFieldByNameOrError(tree, 'RCNLCostTermSet').RCNLCostTerm);
if strcmpi('true', getTextFromField(getFieldByName(tree, ...
        'enforce_bilateral_symmetry')))
    params.costTerms{end+1} = struct('type', 'bilateral_symmetry', ...
        'isEnabled', true, 'maxAllowableError', 1e-4, 'errorCenter', 0);
end
params.diffMinChange = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'diff_min_change', '1e-6')));
params.stepTolerance = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'step_tolerance', '1e-16')));
params.optimalityTolerance = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'optimality_tolerance', '1e-3')));
params.functionTolerance = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'function_tolerance', '1e-6')));
params.maxIterations = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'max_iterations', '1e3')));
params.maxFunctionEvaluations = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'max_function_evaluations', '1e6')));
params.algorithm = string(getTextFromField( ...
    getFieldByNameOrAlternate(tree, 'algorithm', 'interior-point')));
params.FiniteDifferenceStepSize = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'FiniteDifferenceStepSize', '1e-4')));
end

function [optimalFiberLengthScaleFactors, ...
    tendonSlackLengthScaleFactors, maxIsometricForce] = ...
    getMtpDataInputs(inputs)
mtpData = inputs.mtpMuscleData;
muscleNames = inputs.muscleTendonColumnNames;

optimalFiberLengthScaleFactors = zeros(1, length(muscleNames));
tendonSlackLengthScaleFactors = zeros(1, length(muscleNames));
maxIsometricForce = inputs.maxIsometricForce;
if isfield(mtpData, "muscles")
    mtpDataMuscleNames = fieldnames(mtpData.muscles);
else
    throw(MException('',  ...
        "input osimx file contains no RCNLMuscle elements"))
end
for i = 1 : length(muscleNames)
    if ismember(muscleNames(i), mtpDataMuscleNames)
        currentMuscle = mtpData.muscles.(muscleNames(i));
        if isfield(currentMuscle, 'optimalFiberLength')
            optimalFiberLengthScaleFactors(i) = currentMuscle.optimalFiberLength / inputs.optimalFiberLength(i);
        else
            optimalFiberLengthScaleFactors(i) = 1;
        end
        if isfield(currentMuscle, 'tendonSlackLength')
            tendonSlackLengthScaleFactors(i) = currentMuscle.tendonSlackLength / inputs.tendonSlackLength(i);
        else
            tendonSlackLengthScaleFactors(i) = 1;
        end
        if isfield(currentMuscle, 'maxIsometricForce')
            maxIsometricForce(i) = currentMuscle.maxIsometricForce;
        end
    else
        optimalFiberLengthScaleFactors(i) = 1;
        tendonSlackLengthScaleFactors(i) = 1;
    end
end
end
