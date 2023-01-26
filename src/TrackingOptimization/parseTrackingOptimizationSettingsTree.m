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
inputData = load('inputData.mat');
inputs.numRightSynergies = 6;
inputs.numLeftSynergies = 6;
inputs.numMusclesPerSide = 74;
inputs.numMusclesPerLeg = 45;
inputs.numMusclesPerTorso = 29;
inputs.numCoordinates = 31;
inputs.coordinateNames = inputData.params.coordinateNames;
inputs.minPath = inputData.params.minPath;
inputs.maxPath = inputData.params.maxPath;
inputs.minIntegral = inputData.params.minIntegral;
inputs.maxIntegral = inputData.params.maxIntegral;
inputs.minTerminal = inputData.params.eventgroup.lower;
inputs.maxTerminal = inputData.params.eventgroup.upper;
inputs.splineLeftGroundReactionForces = inputData.params.splineLeftGroundReactionForces;
inputs.splineRightGroundReactionForces = inputData.params.splineRightGroundReactionForces;
inputs.springPointsOnBody = inputData.params.springPointsOnBody;
inputs.springBody = inputData.params.springBody;
inputs.rightMidfootSuperiorPointOnBody = inputData.params.rightMidfootSuperiorPointOnBody;
inputs.rightMidfootSuperiorBody = inputData.params.rightMidfootSuperiorBody;
inputs.leftMidfootSuperiorPointOnBody = inputData.params.leftMidfootSuperiorPointOnBody;
inputs.leftMidfootSuperiorBody = inputData.params.leftMidfootSuperiorBody;
inputs.rightHeelPointOnBody = inputData.params.rightHeelPointOnBody;
inputs.rightHeelBody = inputData.params.rightHeelBody;
inputs.leftHeelPointOnBody = inputData.params.leftHeelPointOnBody;
inputs.leftHeelBody = inputData.params.leftHeelBody;
inputs.rightToePointOnBody = inputData.params.rightToePointOnBody;
inputs.rightToeBody = inputData.params.rightToeBody;
inputs.leftToePointOnBody = inputData.params.leftToePointOnBody;
inputs.leftToeBody = inputData.params.leftToeBody;
inputs.leftToeBody = inputData.params.leftToeBody;
inputs.springDamping = inputData.params.springDamping;
inputs.dynamicFriction = inputData.params.dynamicFriction;
inputs.springStiffness = inputData.params.springStiffness;
inputs.viscousFriction = inputData.params.viscousFriction;
inputs.latchingVelocity = inputData.params.latchingVelocity;
inputs.numSpringsRightHeel = inputData.params.numSpringsRightHeel;
inputs.numSpringsLeftHeel = inputData.params.numSpringsLeftHeel;
inputs.numSpringsRightToe = inputData.params.numSpringsRightToe;
inputs.numSpringsLeftToe = inputData.params.numSpringsLeftToe;
inputs.dofsActuated = inputData.params.dofsActuated;
inputs.epsilon = inputData.params.epsilon;
inputs.optimalFiberLength = inputData.params.optimalFiberLength;
inputs.tendonSlackLength = inputData.params.tendonSlackLength;
inputs.pennationAngle = inputData.params.pennationAngle;
inputs.maxIsometricForce = inputData.params.maxIsometricForce;
inputs.numActuators = inputData.params.numActuators;
inputs.inverseDynamicMomentsIndex = inputData.params.inverseDynamicMomentsIndex;
inputs.pelvisResidualsIndex = inputData.params.pelvisResidualsIndex;
inputs.muscleActuatedMomentsIndex = inputData.params.muscleActuatedMomentsIndex;
inputs.polynomialExpressionMomentArms = inputData.params.polynomialExpressionMomentArms;
inputs.polynomialExpressionMuscleTendonLengths = inputData.params.polynomialExpressionMuscleTendonLengths;
inputs.coefficients = inputData.params.coefficients;
inputs.integralOptions = inputData.params.integralOptions;
inputs.isEnabled = inputData.params.isEnabled;
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
inputs.initialGuessFileName = getFieldByName(tree, 'initial_guess_file').Text;
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
experimentalGroundReactions = parseTreatmentOptimizationStandard(...
    findFileListFromPrefixList(fullfile(inputDirectory, "GRFData"), prefixes));

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
inputs = getIntegralCostTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationIntegralTerms'), inputs);
inputs = getPathConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationPathConstraints'), inputs);
inputs = getTerminalConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationTerminalConstraints'), inputs);
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

function inputs = getIntegralCostTerms(tree, inputs)
trackingIntegralTermsTree = getFieldByNameOrError(tree, 'TrackingTerms');
minimizingIntegralTermsTree = getFieldByNameOrError(tree, 'MinimizingTerms');
trackingIntegralTerms = {'JointAngles', 'JointMoments', ...
    'GroundReactionForces', 'GroundReactionMoments', 'MuscleActivations'};
trackingIntegralTermNames = {'trackingJointAngles', 'trackingJointMoments', ...
    'trackingGroundReactionForces', 'trackingGroundReactionMoments', ...
    'trackingMuscleActivations'};
for i = 1 : length(trackingIntegralTerms)
    inputs = addIntegralCostTerms(getFieldByNameOrError(...
        trackingIntegralTermsTree, trackingIntegralTerms{i}), ...
        trackingIntegralTermNames{i}, inputs);
end
minimizingIntegralTerms = {'JointJerk'};
minimizingIntegralTermNames = {'minimizingJointJerk'};
for i = 1 : length(minimizingIntegralTerms)
    inputs = addIntegralCostTerms(getFieldByNameOrError(...
        minimizingIntegralTermsTree, minimizingIntegralTerms{i}), ...
        minimizingIntegralTermNames{i}, inputs);
end
end

function inputs = addIntegralCostTerms(tree, ...
    integralCostTermName, inputs)
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true")
    inputs.(strcat(integralCostTermName, "Enabled")) = 1;
else
    inputs.(strcat(integralCostTermName, "Enabled")) = 0;
end
% maxError = getFieldByNameOrError(tree, "max_allowable_error");
% maxError = str2num(maxError.Text);
end

function inputs = getPathConstraintTerms(tree, inputs)
pathConstraintTerms = {'RootSegmentResidualLoads', 'MuscleModelMomentConsistency'};
for i = 1 : length(pathConstraintTerms)
    inputs = addPathConstraintTerms(getFieldByNameOrError(...
        tree, pathConstraintTerms{i}), pathConstraintTerms{i}, inputs);
end
end

function inputs = addPathConstraintTerms(tree, ...
    pathConstraintTermName, inputs)
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true")
    inputs.(strcat([lower(pathConstraintTermName(1)) ...
        pathConstraintTermName(2:end)], "PathConstraint")) = 1;
else
    inputs.(strcat([lower(pathConstraintTermName(1)) ...
        pathConstraintTermName(2:end)], "PathConstraint")) = 0;
end
% maxError = getFieldByNameOrError(tree, "max_allowable_error");
% maxError = str2num(maxError.Text);
end

function inputs = getTerminalConstraintTerms(tree, inputs)
terminalConstraintTerms = {'StatePositionPeriodicity', ...
    'StateVelocityPeriodicity', 'RootSegmentResidualLoadPeriodicity', ...
    'GroundReactionForcesPeriodicity', 'GroundReactionMomentsPeriodicity', ...
    'SynergyWeightsSum'};
for i = 1 : length(terminalConstraintTerms)
    inputs = addTerminalConstraintTerms(getFieldByNameOrError(...
        tree, terminalConstraintTerms{i}), terminalConstraintTerms{i}, ...
        inputs);
end
end

function inputs = addTerminalConstraintTerms(tree, ...
    terminalConstraintTerms, inputs)
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true")
    inputs.(strcat([lower(terminalConstraintTerms(1)) ...
        terminalConstraintTerms(2:end)], "Constraint")) = 1;
else
    inputs.(strcat([lower(terminalConstraintTerms(1)) ...
        terminalConstraintTerms(2:end)], "Constraint")) = 0;
end
% maxError = getFieldByNameOrError(tree, "max_allowable_error");
% maxError = str2num(maxError.Text);
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
params.solverType = getFieldByNameOrError(tree, 'solver_type').Text;
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