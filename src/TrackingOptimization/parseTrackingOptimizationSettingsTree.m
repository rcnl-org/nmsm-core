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
inputs = getModelInputs(inputs);
inputs = updateModel(inputs);
inputs = getStateDerivatives(inputs);
inputs = checkInitialGuess(inputs);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end

inputs.synergyWeights = inputs.initialGuess.parameter;
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
import org.opensim.modeling.Storage
dataDirectory = getFieldByName(tree, 'data_directory').Text;
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
if(~isempty(dataDirectory))
    try
        inputs.model = fullfile(dataDirectory, modelFile);
    catch
        inputs.model = fullfile(pwd, dataDirectory, modelFile);
        dataDirectory = fullfile(pwd, dataDirectory);
    end
else
    inputs.model = fullfile(pwd, modelFile);
    dataDirectory = pwd;
end

inputs.controllerType = getFieldByNameOrError(tree, 'type_of_controller').Text;
inputs.osimxFile = getFieldByName(tree, 'osimx_file').Text;
inputs.ncpDataInputs = parseNCPOsimxFile(inputs.osimxFile);
inputs.synergyGroups = getSynergyGroups(tree, Model(inputs.model));
inputs.numSynergies = 0;
inputs.numSynergyWeights = 0;
for i = 1 : length(inputs.synergyGroups)
    inputs.numSynergies = inputs.numSynergies + ...
    inputs.synergyGroups{i}.numSynergies;
    inputs.numSynergyWeights = inputs.numSynergyWeights + ...
        length(inputs.synergyGroups{i}.muscleNames) * ...
        inputs.synergyGroups{i}.numSynergies;
end

inputs.initialGuess = getTrackingOptimizationInitialGuess(tree);

optimizeSynergyVectors = getFieldByName(tree, 'optimize_synergy_vectors');
if(isstruct(optimizeSynergyVectors))
    if strcmpi(optimizeSynergyVectors.Text, 'true')
        inputs.optimizeSynergyVectors = 1;
    else 
        inputs.optimizeSynergyVectors = 0;
    end
end

prefixes = getPrefixes(tree, dataDirectory);
inverseDynamicsFileNames = findFileListFromPrefixList(fullfile( ...
    dataDirectory, "IDData"), prefixes);
inputs.inverseDynamicMomentLabels = getStorageColumnNames(Storage( ...
    inverseDynamicsFileNames(1)));
inputs.experimentalJointMoments = parseTreatmentOptimizationStandard( ...
    inverseDynamicsFileNames);
inputs.numActuators = size(inputs.experimentalJointMoments, 2);

coordinateFileName = findFileListFromPrefixList(fullfile( ...
    dataDirectory, "IKData"), prefixes);
inputs.coordinateNames = cellstr(getStorageColumnNames(Storage( ...
    coordinateFileName(1))));
inputs.experimentalJointAngles = parseTreatmentOptimizationStandard( ...
    coordinateFileName);
inputs.experimentalTime = parseTimeColumn(coordinateFileName)';
inputs.numCoordinates = size(inputs.experimentalJointAngles, 2);

muscleActivationFileName = findFileListFromPrefixList(fullfile( ...
    dataDirectory, "ActData"), prefixes);
inputs.muscleLabels = getStorageColumnNames(Storage( ...
    muscleActivationFileName(1)));
inputs.experimentalMuscleActivations = parseTreatmentOptimizationStandard( ...
    muscleActivationFileName);
inputs.numMuscles = length(inputs.muscleLabels);

% Need to extract electrical center from here
experimentalGroundReactions = parseTreatmentOptimizationStandard(...
    findFileListFromPrefixList(fullfile(dataDirectory, "GRFData"), prefixes));


% load in surrogate model params
inputs.experimentalTime = inputs.experimentalTime - inputs.experimentalTime(1);

inputs = getDesignVariableBounds(tree, inputs);
inputs = getIntegralCostTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationIntegralTerms'), inputs);
inputs = getPathConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationPathConstraintTerms'), inputs);
inputs = getTerminalConstraintTerms(getFieldByNameOrError(tree, ...
    'TrackingOptimizationTerminalConstraintTerms'), inputs);
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

function solverSettings = getOptimalControlSolverSettings(settingsFileName)
solverSettingsTree = xml2struct(settingsFileName);

solverSettings.optimizationFileName = 'trackingOptimizationOutputFile.txt';
solverSettings.solverType = getTextFromField(getFieldByNameOrAlternate( ...
    solverSettingsTree, 'solver_type', 'ipopt'));
solverSettings.linearSolverType = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'linear_solver_type', 'ma57'));
solverSettings.solverTolerance = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'solver_tolerance', '1e-3')));
solverSettings.stepSize = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'step_size', '1e-8')));
solverSettings.maxIterations = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'max_iterations', '2e4')));
solverSettings.derivativeApproximation = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'derivative_approximation', 'sparseCD'));
solverSettings.derivativeOrder = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'derivative_order', 'first'));
solverSettings.derivativeDependencies = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'derivative_dependencies', 'sparse'));
solverSettings.meshMethod = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'mesh_method', ''));
solverSettings.meshTolerance = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'mesh_tolerance', ''));
solverSettings.meshMaxIterations = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'mesh_max_iterations', '0')));
solverSettings.method = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'method', ''));
solverSettings.collocationPoints = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'collocation_points', '5')));
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
maxControlNeuralCommands = getFieldByNameOrError(designVariableTree, ...
    'synergy_commands');
if(isstruct(maxControlNeuralCommands))
    inputs.maxControlNeuralCommands = ...
        str2double(maxControlNeuralCommands.Text);
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

function inputs = addIntegralCostTerms(tree, ...
    integralCostTerm, inputs)
integralCostTermName = integralCostTerm;
integralCostTermName(1) = upper(integralCostTermName(1));
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true")
    inputs.(strcat(integralCostTerm, "Enabled")) = 1;
else
    inputs.(strcat(integralCostTerm, "Enabled")) = 0;
end
costWeight = getFieldByNameOrError(tree, "cost_weight").Text;
inputs.(strcat(integralCostTerm, "CostWeight")) = str2double(costWeight);

if isstruct(getFieldByName(tree, 'max_allowable_error'))
    maxAllowableError = ... 
        getFieldByNameOrError(tree, "max_allowable_error").Text;
    inputs.(strcat(integralCostTerm, "MaxAllowableError")) = ...
        str2double(maxAllowableError);
end

if  iscell(getFieldByName(tree, integralCostTermName))
    inputs.(integralCostTerm) = ...
        getAllowableError(tree.(integralCostTermName));
end
end

function [output] = getAllowableError(tree)
counter = 1;
for i=1:length(tree)
    if(length(tree) == 1)
        quantity = tree;
    else
        quantity = tree{i};
    end
    if (quantity.is_enabled.Text == "true")
        output.names{counter} = quantity.Attributes.name;
        output.maxAllowableErrors(counter) = ...
            str2double(quantity.max_allowable_error.Text);
        if isstruct(getFieldByName(quantity, 'min_allowable_error'))
            output.minAllowableErrors(counter) = ...
                str2double(quantity.min_allowable_error.Text);
        end
        if isstruct(getFieldByName(quantity, 'body'))
            output.body{counter} = quantity.body.Text;
        end
        if isstruct(getFieldByName(quantity, 'point'))
            output.point(counter, :) = ...
                str2double(regexp(quantity.point.Text,'\S*','match'));
        end
        counter = counter + 1;
    end
end
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

function inputs = addPathConstraintTerms(tree, ...
    pathConstraintTerm, inputs)
pathConstraintTermName = pathConstraintTerm;
pathConstraintTermName(1) = upper(pathConstraintTermName(1));
enabled = getFieldByNameOrError(tree, "is_enabled").Text;
if(enabled == "true")
    inputs.(strcat(pathConstraintTerm, "PathConstraint")) = 1;
else
    inputs.(strcat(pathConstraintTerm, "PathConstraint")) = 0;
end

if  iscell(getFieldByName(tree, pathConstraintTermName))
    inputs.(pathConstraintTerm) = ...
        getAllowableError(tree.(pathConstraintTermName));
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
synergyWeightsSumTree = getFieldByNameOrError(tree, ...
    'SynergyWeightsSum');
inputs = addTerminalConstraintTerms(synergyWeightsSumTree, ...
        'synergyWeightsSum', inputs);
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
maxAllowableError = getFieldByNameOrError(tree, "max_allowable_error").Text;
inputs.(strcat(terminalConstraintTerms, "MaxAllowableError")) = ...
    str2double(maxAllowableError);
minAllowableError = getFieldByNameOrError(tree, "min_allowable_error").Text;
inputs.(strcat(terminalConstraintTerms, "MinAllowableError")) = ...
    str2double(minAllowableError);
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

params.solverSettings = getOptimalControlSolverSettings(...
    getTextFromField(getFieldByName(tree, 'optimal_control_settings_file')));
end

function inputs = getStateDerivatives(inputs)
for i = 1 : size(inputs.experimentalJointAngles, 2)
    inputs.experimentalJointVelocities (:, i) = calcDerivative(...
        inputs.experimentalTime, inputs.experimentalJointAngles(:, i));
    inputs.experimentalJointAccelerations (:, i) = calcDerivative(...
        inputs.experimentalTime, inputs.experimentalJointVelocities(:, i));
    inputs.experimentalJointJerks (:, i) = calcDerivative(...
        inputs.experimentalTime, inputs.experimentalJointAccelerations(:, i));
end
end

function inputs = getModelInputs(inputs)
if ~isa(inputs.model, 'org.opensim.modeling.Model')
    model = Model(inputs.model);
end
inputs.numMuscles = getNumEnabledMuscles(inputs.model);
inputs.optimalFiberLength = [];
inputs.tendonSlackLength = [];
inputs.pennationAngle = [];
inputs.maxIsometricForce = [];
inputs.muscleNames = '';
for i = 0:model.getForceSet().getMuscles().getSize()-1
    if model.getForceSet().getMuscles().get(i).get_appliesForce()
        inputs.muscleNames{end+1} = char(model.getForceSet(). ...
            getMuscles().get(i).getName);
        if isfield(inputs.ncpDataInputs, inputs.muscleNames{end})
            inputs.optimalFiberLength(end+1) = inputs.ncpDataInputs. ...
                (inputs.muscleNames{end}).optimalTendonLength;
            inputs.tendonSlackLength(end+1) = inputs.ncpDataInputs. ...
                (inputs.muscleNames{end}).tendonSlackLength;
            if isfield(inputs.ncpDataInputs. ...
                    (inputs.muscleNames{end}), 'maxIsometricForce')
                inputs.maxIsometricForce(end+1) = inputs.ncpDataInputs. ...
                    (inputs.muscleNames{end}).maxIsometricForce;
            else
                inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
                    getMuscles().get(i).getMaxIsometricForce();
            end
        else
            inputs.optimalFiberLength(end+1) = model.getForceSet(). ...
                getMuscles().get(i).getOptimalFiberLength();
            inputs.tendonSlackLength(end+1) = model.getForceSet(). ...
                getMuscles().get(i).getTendonSlackLength();
            inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
                getMuscles().get(i).getMaxIsometricForce();
        end
        inputs.pennationAngle(end+1) = model.getForceSet(). ...
            getMuscles().get(i). ...
            getPennationAngleAtOptimalFiberLength();
    end
end
end

function inputs = updateModel(inputs)
if ~isa(inputs.model, 'org.opensim.modeling.Model')
    model = Model(inputs.model);
end
inputs.numTotalMuscles = model.getForceSet().getMuscles().getSize();
for i = 0:model.getForceSet().getMuscles().getSize()-1
    if model.getForceSet().getMuscles().get(i).get_appliesForce()
        model.getForceSet().getMuscles().get(i).set_appliesForce(0);
    end
end
inputs.mexModel = strcat(strrep(inputs.model,'.osim',''), '_inactiveMuscles.osim');
model.print(inputs.mexModel);
end

function data = parseNCPOsimxFile(filename)
tree = xml2struct(filename);
ncpMuscleSetTree = getFieldByNameOrError(tree, "NCPMuscleSet");
musclesTree = getFieldByNameOrError(ncpMuscleSetTree, "objects").RCNLMuscle;
for i = 1:length(musclesTree)
    if(length(musclesTree) == 1)
        muscle = musclesTree;
    else
        muscle = musclesTree{i};
    end
    data.(muscle.Attributes.name).optimalTendonLength = ...
        str2double(muscle.optimal_fiber_length.Text);    
    data.(muscle.Attributes.name).tendonSlackLength = ...
        str2double(muscle.slack_tendon_length.Text);
    if isfield(muscle,'max_isometric_force')
        data.(muscle.Attributes.name).maxIsometricForce = ...
            str2double(muscle.max_isometric_force.Text);
    end
end
end

function initialGuess = getTrackingOptimizationInitialGuess(tree)
import org.opensim.modeling.Storage
initialGuess = [];

stateFileName = getTextFromField(getFieldByNameOrAlternate(tree, ...
    'initial_states_file', ''));
if ~isempty(stateFileName)
    initialGuess.time = parseTimeColumn({stateFileName})';
    initialGuess.stateLabels = getStorageColumnNames(Storage({stateFileName}));
    initialGuess.state = parseTreatmentOptimizationStandard({stateFileName});
end
controlFileName = getTextFromField(getFieldByNameOrAlternate(tree, ...
    'initial_controls_file', ''));
if ~isempty(controlFileName)
    initialGuess.controlLabels = getStorageColumnNames(Storage({controlFileName}));
    initialGuess.control = parseTreatmentOptimizationStandard({controlFileName});
end
parameterFileName = getTextFromField(getFieldByNameOrAlternate(tree, ...
    'initial_parameters_file', ''));
if ~isempty(parameterFileName)
    initialGuess.parameterLabels = getStorageColumnNames(Storage({parameterFileName}));
    initialGuess.parameter = parseTreatmentOptimizationStandard({parameterFileName});
end
end

function inputs = checkInitialGuess(inputs)
if isfield(inputs.initialGuess,'state')
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
if isfield(inputs.initialGuess,'control')
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
if isfield(inputs.initialGuess,'parameter')
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