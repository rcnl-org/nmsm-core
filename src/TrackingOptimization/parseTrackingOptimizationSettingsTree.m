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
inputs = getModelOrOsimxInputs(inputs);
inputs = disableModelMuscles(inputs);
inputs = getStateDerivatives(inputs);
inputs = checkInitialGuess(inputs);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end

%% missing GCP inputs
inputData = load([cd '\inputData.mat']);
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
inputs.springDamping = inputData.params.springDamping;
inputs.dynamicFriction = inputData.params.dynamicFriction;
inputs.springStiffness = inputData.params.springStiffness;
inputs.viscousFriction = inputData.params.viscousFriction;
inputs.latchingVelocity = inputData.params.latchingVelocity;
inputs.numSpringsRightHeel = inputData.params.numSpringsRightHeel;
inputs.numSpringsLeftHeel = inputData.params.numSpringsLeftHeel;
inputs.numSpringsRightToe = inputData.params.numSpringsRightToe;
inputs.numSpringsLeftToe = inputData.params.numSpringsLeftToe;

%% surrogate model inputs
inputs.polynomialExpressionMomentArms = inputData.params.polynomialExpressionMomentArms;
inputs.polynomialExpressionMuscleTendonLengths = inputData.params.polynomialExpressionMuscleTendonLengths;
inputs.coefficients = [inputData.params.coefficients(1:45) inputData.params.coefficients(75:119)];
inputs.dofsActuated = [inputData.params.dofsActuated(:,1:45) inputData.params.dofsActuated(:,75:119)] ;
inputs.dofsActuatedLabels = {'pelvis_tilt_moment' 'pelvis_list_moment' ...
    'pelvis_rotation_moment' 'pelvis_tx_force' 'pelvis_ty_force' ....
    'pelvis_tz_force' 'hip_flexion_r_moment' 'hip_adduction_r_moment' ...
    'hip_rotation_r_moment' 'knee_angle_r_moment' 'ankle_angle_r_moment' ...
    'subtalar_angle_r_moment' 'mtp_angle_r_moment' 'hip_flexion_l_moment' ...
    'hip_adduction_l_moment' 'hip_rotation_l_moment' 'knee_angle_l_moment' ...
    'ankle_angle_l_moment' 'subtalar_angle_l_moment' 'mtp_angle_l_moment' ...
    'lumbar_extension_moment' 'lumbar_bending_moment' ...
    'lumbar_rotation_moment' 'arm_flex_r_moment' 'arm_add_r_moment'	...
    'arm_rot_r_moment' 'elbow_flex_r_moment' 'arm_flex_l_moment' ...
    'arm_add_l_moment' 'arm_rot_l_moment' 'elbow_flex_l_moment'};
inputs.epsilon = inputData.params.epsilon;

%%
load([cd '\experimentalData.mat'])
inputs.experimentalRightGroundReactions = experimentalRightGroundReactions;
inputs.rightGroundReactionLabels = {'ground_reaction_force_x1', ...
    'ground_reaction_force_y1', 'ground_reaction_force_z1', ...
    'ground_reaction_moment_x1', 'ground_reaction_moment_y1', ...
    'ground_reaction_moment_z1'};
inputs.experimentalLeftGroundReactions = experimentalLeftGroundReactions;
inputs.leftGroundReactionLabels = {'ground_reaction_force_x', ...
    'ground_reaction_force_y', 'ground_reaction_force_z', ...
    'ground_reaction_moment_x', 'ground_reaction_moment_y', ...
    'ground_reaction_moment_z'};

end

function inputs = getInputs(tree)
inputs = parseTrackingOptimizationDataDirectory(tree);
inputs.model = parseModel(tree);
inputs.controllerType = getFieldByNameOrError(tree, 'type_of_controller').Text;
osimxFile = getTextFromField(getFieldByNameOrAlternate(tree, 'osimx_file'));
inputs.ncpDataInputs = parseNCPOsimxFile(osimxFile);
inputs.synergyGroups = getSynergyGroups(tree, Model(inputs.model));
inputs.numSynergies = getNumSynergies(inputs.synergyGroups);
inputs.numSynergyWeights = getNumSynergyWeights(inputs.synergyGroups);
inputs.initialGuess = getGpopsInitialGuess(tree);
inputs.optimizeSynergyVectors = getBooleanLogicFromField( ...
    getFieldByName(tree, 'optimize_synergy_vectors'));
inputs = getDesignVariableBounds(tree, inputs);
inputs = getIntegralCostTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationIntegralTerms'), inputs);
inputs = getPathConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationPathConstraintTerms'), inputs);
inputs = getTerminalConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationTerminalConstraintTerms'), inputs);
inputs.beltSpeed = getDoubleFromField(getFieldByName(tree, 'belt_speed'));
inputs.epsilon = str2double(parseElementTextByNameOrAlternate(tree, ...
    "epsilon", "1e-3"));
inputs.vMaxFactor = str2double(parseElementTextByNameOrAlternate(tree, ...
    "v_max_factor", "10"));
end

function inputs = parseTrackingOptimizationDataDirectory(tree)
dataDirectory = parseDataDirectory(tree);
prefix = findPrefixes(tree, dataDirectory);

directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "IDData");
[inputs.experimentalJointMoments, inputs.inverseDynamicMomentLabels] = ...
    parseTreatmentOptimizationData(directory, prefix);
inputs.numActuators = size(inputs.experimentalJointMoments, 2);

directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "IKData");
[inputs.experimentalJointAngles, inputs.coordinateNames] = ...
    parseTreatmentOptimizationData(directory, prefix);
inputs.numCoordinates = size(inputs.experimentalJointAngles, 2);

directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "ActData");
[inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
    parseTreatmentOptimizationData(directory, prefix);
inputs.numCoordinates = size(inputs.experimentalJointAngles, 2);

experimentalTime = parseTimeColumn(findFileListFromPrefixList(...
    fullfile(dataDirectory, "IKData"), prefix))';
inputs.experimentalTime = experimentalTime - experimentalTime(1);

directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "GRFData");
[inputs.experimentalGroundReactions, inputs.groundReactionLabels] = ...
    parseTreatmentOptimizationData(directory, prefix);
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

function inputs = getDesignVariableBounds(tree, inputs)
designVariableTree = getFieldByNameOrError(tree, ...
    'TrackingOptimizationDesignVariableBounds');
jointPositionsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_positions');
if(isstruct(jointPositionsMultiple))
    inputs.statePositionsMultiple = getDoubleFromField(jointPositionsMultiple);
end
jointVelocitiesMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_velocities');
if(isstruct(jointVelocitiesMultiple))
    inputs.stateVelocitiesMultiple = getDoubleFromField(jointVelocitiesMultiple);
end
jointAccelerationsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_accelerations');
if(isstruct(jointAccelerationsMultiple))
    inputs.stateAccelerationsMultiple = ...
        getDoubleFromField(jointAccelerationsMultiple);
end
jointJerkMultiple = getFieldByNameOrError(designVariableTree, 'joint_jerks');
if(isstruct(jointJerkMultiple))
    inputs.controlJerksMultiple = getDoubleFromField(jointJerkMultiple);
end
maxControlNeuralCommands = getFieldByNameOrError(designVariableTree, ...
    'synergy_commands');
if(isstruct(maxControlNeuralCommands))
    inputs.maxControlNeuralCommands = ...
        getDoubleFromField(maxControlNeuralCommands);
end
maxParameterSynergyWeights = getFieldByNameOrError(designVariableTree, ...
    'synergy_weights');
if(isstruct(maxParameterSynergyWeights))
    inputs.maxParameterSynergyWeights = ...
        getDoubleFromField(maxParameterSynergyWeights);
end
end

function inputs = getIntegralCostTerms(tree, inputs)
trackingIntegralTermsTree = getFieldByNameOrError(tree, 'TrackingTerms');
trackingCoordinatesTree = getFieldByNameOrError(trackingIntegralTermsTree, ...
    'TrackedCoordinateList');
inputs = addIntegralCostTerms(trackingCoordinatesTree, ...
        'trackedCoordinate', inputs);
trackingLoadsTree = getFieldByNameOrError(trackingIntegralTermsTree, ...
    'TrackedInverseDynamicLoadsList');
inputs = addIntegralCostTerms(trackingLoadsTree, ...
        'trackedLoad', inputs);
trackingExternalForcesTree = getFieldByNameOrError(trackingIntegralTermsTree, ...
    'TrackedExternalForceList');
inputs = addIntegralCostTerms(trackingExternalForcesTree, ...
        'trackedExternalForce', inputs);
trackingExternalMomentsTree = getFieldByNameOrError(trackingIntegralTermsTree, ...
    'TrackedExternalMomentList');
inputs = addIntegralCostTerms(trackingExternalMomentsTree, ...
        'trackedExternalMoment', inputs);
trackingMuscleActivationsTree = getFieldByNameOrError(trackingIntegralTermsTree, ...
    'TrackedMuscleActivations');
inputs = addIntegralCostTerms(trackingMuscleActivationsTree, ...
        'trackedMuscleActivation', inputs);

minimizingIntegralTermsTree = getFieldByNameOrError(tree, 'MinimizingTerms');
minimizingJerkTree = getFieldByNameOrError(minimizingIntegralTermsTree, ...
    'MinimizeJointJerk');
inputs = addIntegralCostTerms(minimizingJerkTree, ...
        'minimizedCoordinate', inputs);
end

function inputs = getPathConstraintTerms(tree, inputs)
rootSegmentResidualLoadsTree = getFieldByNameOrError(tree, ...
    'RootSegmentResidualLoads');
inputs = addPathConstraintTerms(rootSegmentResidualLoadsTree, ...
        'rootSegmentResidualLoad', inputs);
muscleModelMomentConsistencyTree = getFieldByNameOrError(tree, ...
    'MuscleModelMomentConsistency');
inputs = addPathConstraintTerms(muscleModelMomentConsistencyTree, ...
        'muscleModelLoad', inputs);
end

function inputs = getTerminalConstraintTerms(tree, inputs)
statePositionPeriodicityTree = getFieldByNameOrError(tree, ...
    'StatePositionPeriodicity');
inputs = addTerminalConstraintTerms(statePositionPeriodicityTree, ...
        'statePositionPeriodicity', inputs);
stateVelocityPeriodicityTree = getFieldByNameOrError(tree, ...
    'StateVelocityPeriodicity');
inputs = addTerminalConstraintTerms(stateVelocityPeriodicityTree, ...
        'stateVelocityPeriodicity', inputs);
rootSegmentResidualLoadPeriodicityTree = getFieldByNameOrError(tree, ...
    'RootSegmentResidualLoadPeriodicity');
inputs = addTerminalConstraintTerms(rootSegmentResidualLoadPeriodicityTree, ...
        'rootSegmentResidualLoadPeriodicity', inputs);
externalForcePeriodicityTree = getFieldByNameOrError(tree, ...
    'ExternalForcePeriodicity');
inputs = addTerminalConstraintTerms(externalForcePeriodicityTree, ...
        'externalForcePeriodicity', inputs);
externalMomentPeriodicityTree = getFieldByNameOrError(tree, ...
    'ExternalMomentPeriodicity');
inputs = addTerminalConstraintTerms(externalMomentPeriodicityTree, ...
        'externalMomentPeriodicity', inputs);
synergyWeightsSumTree = getFieldByNameOrError(tree, ...
    'SynergyWeightsSum');
inputs = addTerminalConstraintTerms(synergyWeightsSumTree, ...
        'synergyWeightsSum', inputs);
end

function params = getParams(tree)

params.solverSettings = getOptimalControlSolverSettings(...
    getTextFromField(getFieldByName(tree, 'optimal_control_settings_file')));
end

function inputs = checkInitialGuess(inputs)
if isfield(inputs.initialGuess, 'state')
    for i = 1 : inputs.numCoordinates
        for j = 1 : length(inputs.initialGuess.stateLabels)
            if strcmpi(inputs.coordinateNames(i), inputs.initialGuess.stateLabels(j))
                stateIndex(i) = j;
            end
        end 
    end
    inputs.initialGuess.state = inputs.initialGuess.state(:, [stateIndex ...
    stateIndex + inputs.numCoordinates stateIndex + inputs.numCoordinates * 2]);
end
if isfield(inputs.initialGuess, 'control')
    for i = 1 : inputs.numCoordinates
        for k = 1 : length(inputs.initialGuess.controlLabels)
            if strcmpi(inputs.coordinateNames(i), inputs.initialGuess.controlLabels(k))
                controlIndex(i) = k;
            end
        end 
    end
    inputs.initialGuess.control(:, 1:inputs.numCoordinates) = ...
        inputs.initialGuess.control(:, controlIndex);
end
if isfield(inputs.initialGuess, 'parameter')
    parameterIndex = zeros(length(inputs.synergyGroups), inputs.numMuscles);
    for i = 1 : length(inputs.synergyGroups)
        for j = 1 : inputs.numMuscles
            for k = 1 : length(inputs.synergyGroups{i}.muscleNames)
                if strcmpi(inputs.muscleNames(j), inputs.synergyGroups{i}.muscleNames(k))
                    if i <= 1 
                        parameterIndex(i, k) = j;
                    else
                        parameterIndex(i, k + length(inputs.synergyGroups{i}.muscleNames)) = j;
                    end
                end
            end
        end 
    end
    parameterTemp = [];
    numSynergiesIndex = 0;
    for j = 1 : length(inputs.synergyGroups)
        parameterTemp = cat(2, parameterTemp, ...
            reshape(inputs.initialGuess.parameter(1 + numSynergiesIndex: ...
            inputs.synergyGroups{j}.numSynergies + numSynergiesIndex, ...
            nonzeros(parameterIndex(j, :)))', 1, []));
        numSynergiesIndex = numSynergiesIndex + inputs.synergyGroups{j}.numSynergies;
    end
    inputs.initialGuess.parameter = parameterTemp;
end
end