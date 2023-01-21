% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

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

function [inputs, params, resultsDirectory] = ...
    parseTrackingOptimizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = [];
inputs = getSplines(inputs);
% params = getParams(settingsTree);
% inputs = getModelInputs(inputs);
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
inputs.inverseDynamicMomentLabels = getStorageColumnNames(Storage( ...
    inverseDynamicsFileNames(1)));
inputs.experimentalJointMoments = parseTreatmentOptimizationStandard( ...
    inverseDynamicsFileNames);

jointAngleFileName = findFileListFromPrefixList(fullfile( ...
    inputDirectory, "IKData"), prefixes);
inputs.jointAnglesLabels = getStorageColumnNames(Storage( ...
    jointAngleFileName(1)));
inputs.experimentalJointAngles = parseTreatmentOptimizationStandard( ...
    jointAngleFileName);
inputs.experimentalTime = parseTimeColumn(jointAngleFileName)';

muscleActivationFileName = findFileListFromPrefixList(fullfile( ...
    inputDirectory, "ActData"), prefixes);
inputs.muscleLabels = getStorageColumnNames(Storage( ...
    muscleActivationFileName(1)));
inputs.experimentalMuscleActivations = parseTreatmentOptimizationStandard( ...
    muscleActivationFileName);

% Need to extract electrical center from here
% inputs.experimentalGroundReactions = parseTreatmentOptimizationStandard(findFileListFromPrefixList( ...
%     fullfile(inputDirectory, "GRFData"), prefixes));

inputs.numPaddingFrames = 0;
% inputs.numPaddingFrames = (size(inputs.inverseDynamicMomentLabels, 3) - 101) / 2;
inputs = reduceDataSize(inputs, inputs.numPaddingFrames);
inputs.experimentalTime = inputs.experimentalTime - inputs.experimentalTime(1);

inputs.vMaxFactor = getVMaxFactor(tree);
end

% (struct) -> (Array of string)
function prefixes = getPrefixes(tree, inputDirectory)
prefixField = getFieldByName(tree, 'trial_prefix');
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

function inputs = getSplines(inputs)
inputs.splineJointAngles = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointAngles', 0.0000001);
inputs.splineJointMoments = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointMoments', 0.0000001);
inputs.splineMuscleActivations = spaps(inputs.experimentalTime, ...
    inputs.experimentalMuscleActivations', 0.0000001);
% inputs.splineRightGroundReactionForces = spaps(inputs.experimentalTime, ...
%     inputs.experimentalRightGroundReactions', 0.0000001);
% inputs.splineLeftGroundReactionForces = spaps(inputs.experimentalTime, ...
%     inputs.experimentalLeftGroundReactions', 0.0000001);
end

function inputs = reduceDataSize(inputs, numPaddingFrames)
inputs.experimentalJointMoments = inputs.experimentalJointMoments(:, ...
    numPaddingFrames + 1:end - numPaddingFrames, :);
inputs.experimentalJointAngles = inputs.experimentalJointAngles(:, ...
    numPaddingFrames + 1:end - numPaddingFrames, :);
inputs.experimentalMuscleActivations = ...
    inputs.experimentalMuscleActivations(:, ...
    numPaddingFrames + 1:end - numPaddingFrames, :);
% inputs.experimentalRightGroundReactions = ...
%     inputs.experimentalRightGroundReactions(:, ...
%     numPaddingFrames + 1:end - numPaddingFrames, :);
% inputs.experimentalLeftGroundReactions = ...
%     inputs.experimentalLeftGroundReactions(:, ...
%     numPaddingFrames + 1:end - numPaddingFrames, :);
inputs.experimentalTime = inputs.experimentalTime( ...
    numPaddingFrames + 1:end - numPaddingFrames, :);
end

function vMaxFactor = getVMaxFactor(tree)
vMaxFactor = getFieldByName(tree, 'v_max_factor');
if(isstruct(vMaxFactor))
    vMaxFactor = str2double(vMaxFactor.Text);
else
    vMaxFactor = 10;
end
end