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
params = getParams(settingsTree);
inputs = getModelOrOsimxInputs(inputs);
inputs = disableModelMuscles(inputs);
resultsDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'results_directory'));
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end

%% missing GCP inputs
inputData = load([cd '\inputData.mat']);
inputs.splineLeftGroundReactionForces = inputData.params.splineLeftGroundReactionForces;
inputs.splineRightGroundReactionForces = inputData.params.splineRightGroundReactionForces;
inputs.restingSpringLength = 0.0023; % 0.0144;
inputs.rightMidfootSuperiorPointOnBody = inputData.params.rightMidfootSuperiorPointOnBody;
inputs.leftMidfootSuperiorPointOnBody = inputData.params.leftMidfootSuperiorPointOnBody;
inputs.rightHeelBody = inputData.params.rightHeelBody;
inputs.leftHeelBody = inputData.params.leftHeelBody;
inputs.rightToeBody = inputData.params.rightToeBody;
inputs.leftToeBody = inputData.params.leftToeBody; 
inputs.springDamping = inputData.params.springDamping(1);
inputs.dynamicFriction = inputData.params.dynamicFriction;
inputs.viscousFriction = inputData.params.viscousFriction;
inputs.latchingVelocity = inputData.params.latchingVelocity; 
inputs.springStiffness.rightHeel = inputData.params.springStiffnessRightHeel;
inputs.springStiffness.rightToe = inputData.params.springStiffnessRightToe;
inputs.springStiffness.leftHeel = inputData.params.springStiffnessLeftHeel;
inputs.springStiffness.leftToe = inputData.params.springStiffnessLeftToe;
inputs.rightHeelSpringPositionOnBody = inputData.params.rightHeelSpringPositionOnBody;
inputs.rightToeSpringPositionOnBody = inputData.params.rightToeSpringPositionOnBody;
inputs.leftHeelSpringPositionOnBody = inputData.params.leftHeelSpringPositionOnBody;
inputs.leftToeSpringPositionOnBody = inputData.params.leftToeSpringPositionOnBody;
inputs.leftMidfootSuperiorBody = inputData.params.leftMidfootSuperiorBody;
inputs.rightMidfootSuperiorBody = inputData.params.rightMidfootSuperiorBody;
inputs.rightHeelBody = inputData.params.rightHeelBody;
inputs.rightToeBody = inputData.params.rightToeBody;
inputs.leftHeelBody = inputData.params.leftHeelBody;
inputs.leftToeBody = inputData.params.leftToeBody;

%%
load([cd '\experimentalData.mat'])
inputs.experimentalRightGroundReactions1 = experimentalRightGroundReactions;
inputs.rightGroundReactionLabels = {'ground_reaction_force_x1', ...
    'ground_reaction_force_y1', 'ground_reaction_force_z1', ...
    'ground_reaction_moment_x1', 'ground_reaction_moment_y1', ...
    'ground_reaction_moment_z1'};
inputs.experimentalLeftGroundReactions1 = experimentalLeftGroundReactions;
inputs.leftGroundReactionLabels = {'ground_reaction_force_x', ...
    'ground_reaction_force_y', 'ground_reaction_force_z', ...
    'ground_reaction_moment_x', 'ground_reaction_moment_y', ...
    'ground_reaction_moment_z'};

end

function inputs = getInputs(tree)
inputs.controllerType = getTextFromField(getFieldByNameOrError(tree, ...
    'type_of_controller'));
inputs.model = parseModel(tree);
if strcmp(inputs.controllerType, 'synergy_driven')
osimxFile = getTextFromField(getFieldByName(tree, 'osimx_file'));
inputs.ncpDataInputs = parseNcpOsimxFile(osimxFile);
inputs.synergyGroups = getSynergyGroups(tree, Model(inputs.model));
inputs.numSynergies = getNumSynergies(inputs.synergyGroups);
inputs.numSynergyWeights = getNumSynergyWeights(inputs.synergyGroups);
inputs.surrogateModelCoordinateNames = parseSpaceSeparatedList(tree, ...
    "coordinate_list");
inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
    inputs.surrogateModelCoordinateNames);
inputs.numMuscles = length(inputs.muscleNames);
inputs.epsilon = str2double(parseElementTextByNameOrAlternate(tree, ...
    "epsilon", "1e-4"));
inputs.vMaxFactor = str2double(parseElementTextByNameOrAlternate(tree, ...
    "v_max_factor", "10"));
surrogateModelCoefficients = load(getTextFromField(getFieldByName(tree, ...
    'surrogate_model_coefficients')));
inputs.coefficients = surrogateModelCoefficients.coefficients;
inputs.optimizeSynergyVectors = getBooleanLogicFromField( ...
    getFieldByName(tree, 'optimize_synergy_vectors'));
end
inputs = parseTrackingOptimizationDataDirectory(tree, inputs);
inputs = parseGCPContactSurfaces(inputs, tree);
inputs.initialGuess = getGpopsInitialGuess(tree);
inputs = getDesignVariableBounds(tree, inputs);
inputs = getIntegralCostTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationIntegralTerms'), inputs);
inputs = getPathConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationPathConstraintTerms'), inputs);
inputs = getTerminalConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationTerminalConstraintTerms'), inputs);
inputs.beltSpeed = getDoubleFromField(getFieldByName(tree, 'belt_speed'));
end

function inputs = parseTrackingOptimizationDataDirectory(tree, inputs)
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

if strcmp(inputs.controllerType, 'synergy_driven')
directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "ActData");
[inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
    parseTreatmentOptimizationData(directory, prefix);
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    dataDirectory, "MAData"), prefix);
inputs.momentArms = parseSelectMomentArms(directories, ...
    inputs.surrogateModelCoordinateNames, inputs.muscleNames);
inputs.momentArms = reshape(permute(inputs.momentArms, [1 4 2 3]), [], ...
    length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
inputs = getMuscleSpecificSurrogateModelData(inputs);
end

experimentalTime = parseTimeColumn(findFileListFromPrefixList(...
    fullfile(dataDirectory, "IKData"), prefix))';
inputs.experimentalTime = experimentalTime - experimentalTime(1);

inputs.grfFileName = findFileListFromPrefixList(...
    fullfile(dataDirectory, "GRFData"), prefix);
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
if strcmp(inputs.controllerType, 'synergy_driven')
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
else 
maxControlTorques = getFieldByNameOrError(designVariableTree, ...
    'torque_controls');
if(isstruct(maxControlTorques))
    inputs.maxControlTorquesMultiple = getDoubleFromField(maxControlTorques);
end
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
if strcmp(inputs.controllerType, 'synergy_driven')
trackingMuscleActivationsTree = getFieldByName(trackingIntegralTermsTree, ...
    'TrackedMuscleActivations');
inputs = addIntegralCostTerms(trackingMuscleActivationsTree, ...
        'trackedMuscleActivation', inputs);
end

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
if strcmp(inputs.controllerType, 'synergy_driven')
muscleModelMomentConsistencyTree = getFieldByNameOrError(tree, ...
    'MuscleModelMomentConsistency');
inputs = addPathConstraintTerms(muscleModelMomentConsistencyTree, ...
        'muscleModelLoad', inputs);
elseif strcmp(inputs.controllerType, 'torque_driven')
controllerModelMomentConsistencyTree = getFieldByNameOrError(tree, ...
    'ControllerModelMomentConsistency');
inputs = addPathConstraintTerms(controllerModelMomentConsistencyTree, ...
        'controllerModelLoad', inputs);
inputs.numTorqueControls = length(inputs.controllerModelLoad.names);
end
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
if strcmp(inputs.controllerType, 'synergy_driven')
synergyWeightsSumTree = getFieldByNameOrError(tree, ...
    'SynergyWeightsSum');
inputs = addTerminalConstraintTerms(synergyWeightsSumTree, ...
        'synergyWeightsSum', inputs);
end
end

function params = getParams(tree)

params.solverSettings = getOptimalControlSolverSettings(...
    getTextFromField(getFieldByName(tree, 'optimal_control_settings_file')));
end