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
inputs.restingSpringLength = 0.0023; % 0.0144;
inputs.springDamping = inputData.params.springDamping(1);
inputs.dynamicFriction = inputData.params.dynamicFriction;
inputs.viscousFriction = inputData.params.viscousFriction;
inputs.latchingVelocity = inputData.params.latchingVelocity; 
inputs.contactSurfaces{1}.heelSpringConstants = inputData.params.springStiffnessRightHeel;
inputs.contactSurfaces{1}.toeSpringConstants = inputData.params.springStiffnessRightToe;
inputs.contactSurfaces{2}.heelSpringConstants = inputData.params.springStiffnessLeftHeel;
inputs.contactSurfaces{2}.toeSpringConstants = inputData.params.springStiffnessLeftToe;
inputs.contactSurfaces{1}.heelSpringPointsOnBody = inputData.params.rightHeelSpringPositionOnBody;
inputs.contactSurfaces{1}.toeSpringPointsOnBody = inputData.params.rightToeSpringPositionOnBody;
inputs.contactSurfaces{2}.heelSpringPointsOnBody = inputData.params.leftHeelSpringPositionOnBody;
inputs.contactSurfaces{2}.toeSpringPointsOnBody = inputData.params.leftToeSpringPositionOnBody;
end

function inputs = getInputs(tree)
inputs.controllerType = getTextFromField(getFieldByNameOrError(tree, ...
    'type_of_controller'));
inputs.model = parseModel(tree);
if strcmp(inputs.controllerType, 'synergy_driven')
osimxFile = getTextFromField(getFieldByName(tree, 'osimx_file'));
inputs.ncpDataInputs = parseNCPOsimxFile(osimxFile);
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
inputs.contactSurfaces = parseGCPContactSurfaces(inputs, tree);
inputs.initialGuess = getGpopsInitialGuess(tree);
inputs = getDesignVariableBounds(tree, inputs);
inputs = getIntegralCostTerms(tree, inputs);
inputs = getPathConstraintTerms(tree, inputs);
inputs = getTerminalConstraintTerms(tree, inputs);
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
    'RCNLDesignVariableBoundsTerms');
jointPositionsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_positions_multiple');
if(isstruct(jointPositionsMultiple))
    inputs.statePositionsMultiple = getDoubleFromField(jointPositionsMultiple);
end
jointVelocitiesMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_velocities_multiple');
if(isstruct(jointVelocitiesMultiple))
    inputs.stateVelocitiesMultiple = getDoubleFromField(jointVelocitiesMultiple);
end
jointAccelerationsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_accelerations_multiple');
if(isstruct(jointAccelerationsMultiple))
    inputs.stateAccelerationsMultiple = ...
        getDoubleFromField(jointAccelerationsMultiple);
end
jointJerkMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_jerks_multiple');
if(isstruct(jointJerkMultiple))
    inputs.controlJerksMultiple = getDoubleFromField(jointJerkMultiple);
end
if strcmp(inputs.controllerType, 'synergy_driven')
maxControlNeuralCommands = getFieldByNameOrError(designVariableTree, ...
    'synergy_commands_max');
if(isstruct(maxControlNeuralCommands))
    inputs.maxControlNeuralCommands = ...
        getDoubleFromField(maxControlNeuralCommands);
end
maxParameterSynergyWeights = getFieldByNameOrError(designVariableTree, ...
    'synergy_weights_max');
if(isstruct(maxParameterSynergyWeights))
    inputs.maxParameterSynergyWeights = ...
        getDoubleFromField(maxParameterSynergyWeights);
end
else 
maxControlTorques = getFieldByNameOrError(designVariableTree, ...
    'torque_controls_max');
if(isstruct(maxControlTorques))
    inputs.maxControlTorquesMultiple = getDoubleFromField(maxControlTorques);
end
end
end

function inputs = getIntegralCostTerms(tree, inputs)
trackingIntegralTermsTree = getFieldByNameOrError(tree, ...
    'RCNLTrackingCostTerms');
rcnlCostTermTree = ...
    trackingIntegralTermsTree.RCNLCostTermSet.objects.RCNLCostTerm;
if length(rcnlCostTermTree) > 1
    inputs.tracking = parseRcnlCostTermSet(rcnlCostTermTree);
else
    inputs.tracking = parseRcnlCostTermSet({rcnlCostTermTree});
end

minimizingIntegralTermsTree = getFieldByNameOrError(tree, ...
    'RCNLMinimizationCostTerms');
rcnlCostTermTree = ...
    minimizingIntegralTermsTree.RCNLCostTermSet.objects.RCNLCostTerm;
if length(rcnlCostTermTree) > 1
    inputs.minimizing = parseRcnlCostTermSet(rcnlCostTermTree);
else
    inputs.minimizing = parseRcnlCostTermSet({rcnlCostTermTree});
end
end

function inputs = getPathConstraintTerms(tree, inputs)
pathConstraintTermsTree = getFieldByNameOrError(tree, ...
    'RCNLPathConstraintTerms');
inputs.path = parseRcnlConstraintTermSet(pathConstraintTermsTree. ...
    RCNLConstraintTermSet.objects.RCNLConstraintTerm);
end

function inputs = getTerminalConstraintTerms(tree, inputs)
terminalConstraintTermsTree = getFieldByNameOrError(tree, ...
    'RCNLTerminalConstraintTerms');
inputs.terminal = parseRcnlConstraintTermSet(terminalConstraintTermsTree. ...
    RCNLConstraintTermSet.objects.RCNLConstraintTerm);
end

function params = getParams(tree)
params.solverSettings = getOptimalControlSolverSettings(...
    getTextFromField(getFieldByName(tree, 'optimal_control_settings_file')));
end