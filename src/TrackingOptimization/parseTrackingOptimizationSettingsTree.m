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
inputs = getSplines(inputs);
params = getParams(settingsTree);
% inputs = getModelInputs(inputs);
inputs = getStateDerivatives(inputs);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end

% missing Inputs
inputs.numRightSynergies = 6;
inputs.numLeftSynergies = 6;
inputs.numMuscles = 148;
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
inputs.numCoordinates = length(inputs.experimentalJointAngles);

muscleActivationFileName = findFileListFromPrefixList(fullfile( ...
    inputDirectory, "ActData"), prefixes);
inputs.muscleLabels = getStorageColumnNames(Storage( ...
    muscleActivationFileName(1)));
inputs.experimentalMuscleActivations = parseTreatmentOptimizationStandard( ...
    muscleActivationFileName);
inputs.numMuscles = length(inputs.muscleLabels);

% Need to extract electrical center from here
% inputs.experimentalGroundReactions = parseTreatmentOptimizationStandard(findFileListFromPrefixList( ...
%     fullfile(inputDirectory, "GRFData"), prefixes));

% load in NCP synergy commands and weights

% load in surrogate model params

% load integral options with max bounds
% load path options with max, min bounds
% load terminal constriaint options with max and min bounds
inputs.numPaddingFrames = 0;
% inputs.numPaddingFrames = (size(inputs.inverseDynamicMomentLabels, 3) - 101) / 2;
inputs = reduceDataSize(inputs, inputs.numPaddingFrames);
inputs.experimentalTime = inputs.experimentalTime - inputs.experimentalTime(1);

inputs = getDesignVariableBounds(tree, inputs);

inputs.beltSpeed = getBeltSpeed(tree);
% load in epsilon
inputs.vMaxFactor = getVMaxFactor(tree);
end

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

function inputs = getDesignVariableBounds(tree, inputs)
designVariableTree = getFieldByNameOrError(tree, ...
    'TrackingOptimizationDesignVariableBounds');
jointPositionsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_positions');
if(isstruct(jointPositionsMultiple))
    inputs.statePositionsMultiple = str2double(jointPositionsMultiple.Text);
end
jointVelocitiesMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_velocities');
if(isstruct(jointVelocitiesMultiple))
    inputs.stateVelocitiesMultiple = str2double(jointVelocitiesMultiple.Text);
end
jointAccelerationsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_accelerations');
if(isstruct(jointAccelerationsMultiple))
    inputs.stateAccelerationsMultiple = ...
        str2double(jointAccelerationsMultiple.Text);
end
jointJerkMultiple = getFieldByNameOrError(designVariableTree, 'joint_jerks');
if(isstruct(jointJerkMultiple))
    inputs.controlJerksMultiple = str2double(jointJerkMultiple.Text);
end
maxControlNeuralCommandsRight = getFieldByNameOrError(designVariableTree, ...
    'synergy_commands_right');
if(isstruct(maxControlNeuralCommandsRight))
    inputs.maxControlNeuralCommandsRight = ...
        str2double(maxControlNeuralCommandsRight.Text);
end
maxControlNeuralCommandsLeft = getFieldByNameOrError(designVariableTree, ...
    'synergy_commands_left');
if(isstruct(maxControlNeuralCommandsLeft))
    inputs.maxControlNeuralCommandsLeft = ...
        str2double(maxControlNeuralCommandsLeft.Text);
end
maxParameterSynergyWeights = getFieldByNameOrError(designVariableTree, ...
    'synergy_weights');
if(isstruct(maxParameterSynergyWeights))
    inputs.maxParameterSynergyWeights = ...
        str2double(maxParameterSynergyWeights.Text);
end
end

function beltSpeed = getBeltSpeed(tree)
beltSpeed = getFieldByNameOrError(tree, 'belt_speed');
beltSpeed = str2double(beltSpeed.Text);
end

function vMaxFactor = getVMaxFactor(tree)
vMaxFactor = getFieldByName(tree, 'v_max_factor');
if(isstruct(vMaxFactor))
    vMaxFactor = str2double(vMaxFactor.Text);
else
    vMaxFactor = 10;
end
end

function params = getParams(tree)
params = struct();
params.optimizationFileName = 'trackingOptimizationOutputFile.txt';
solveType = getFieldByNameOrError(tree, 'solver_type');
if(isstruct(solveType))
    params.solveType = str2double(solveType.Text);
end
solverTolerance = getFieldByNameOrError(tree, 'solver_tolerance');
if(isstruct(solverTolerance))
    params.solverTolerance = str2double(solverTolerance.Text);
end
stepSize = getFieldByNameOrError(tree, 'step_size');
if(isstruct(stepSize))
    params.stepSize = str2double(stepSize.Text);
end
collocationPointsMultiple = getFieldByNameOrError(tree, ...
    'collocation_points');
if(isstruct(collocationPointsMultiple))
    params.collocationPointsMultiple = ...
        str2double(collocationPointsMultiple.Text);
end
maxIterations = getFieldByNameOrError(tree, 'max_iterations');
if(isstruct(maxIterations))
    params.maxIterations = str2double(maxIterations.Text);
end
end

function inputs = getStateDerivatives(inputs)

for i = 1 : size(inputs.experimentalJointAngles, 2)
    inputs.experimentalJointVelocities (:, i) = calcDerivative(...
        inputs.experimentalTime, inputs.experimentalJointAngles(:, i));
    inputs.experimentalJointAccelerations (:, i) = calcDerivative(...
        inputs.experimentalTime, inputs.experimentalJointAngles(:, i));
    inputs.experimentalJointJerks (:, i) = calcDerivative(...
        inputs.experimentalTime, inputs.experimentalJointAngles(:, i));
end
end