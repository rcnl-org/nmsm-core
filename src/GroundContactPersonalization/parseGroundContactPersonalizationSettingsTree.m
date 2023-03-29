% This function is part of the NMSM Pipeline, see file for full license.
%
% Parses XML settings for Ground contact personalization to determine
% intial inputs and parameters for optimization. 
%
% (struct) -> (struct, struct, string)
% Returns the input values for Ground Contact Personalization.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2022 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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
    parseGroundContactPersonalizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end

function inputs = getInputs(tree)
import org.opensim.modeling.*
inputDirectory = getTextFromField(getFieldByNameOrAlternate(tree, ...
    'input_directory', pwd));
inputs.bodyModel = getFieldByNameOrError(tree, 'input_model_file').Text;
motionFile = getFieldByNameOrError(tree, 'input_motion_file').Text;
grfFile = getFieldByNameOrError(tree, 'input_grf_file').Text;
inputs.kinematicsFilterCutoff = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(tree, 'kinematics_filter_cutoff', '6')));
inputs.latchingVelocity = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(tree, 'latching_velocity', '0.05')));
if(~isempty(inputDirectory))
    try
        bodyModel = Model(fullfile(inputDirectory, inputs.bodyModel));
        inputs.motionFileName = fullfile(inputDirectory, motionFile);
        inputs.grfFileName = fullfile(inputDirectory, grfFile);
    catch
        bodyModel = Model(fullfile(pwd, inputDirectory, inputs.bodyModel));
        inputs.motionFileName = fullfile(pwd, inputDirectory, motionFile);
        inputs.grfFileName = fullfile(pwd, inputDirectory, grfFile);
        inputDirectory = fullfile(pwd, inputDirectory);
    end
else
    bodyModel = Model(fullfile(pwd, inputs.bodyModel));
    inputs.motionFileName = fullfile(pwd, motionFile);
    inputs.grfFileName = fullfile(pwd, grfFile);
    inputDirectory = pwd;
end

% Get inputs for each foot
inputs.tasks = getFootTasks(inputs, tree);
inputs = getInitialValues(inputs, tree);
end

% (struct, struct) -> (struct)
% Gets inputs specific to each foot, such as experimental kinematics and
% ground reactions and foot marker names. 
function output = getFootTasks(inputs, tree)
tasks = getFieldByNameOrError(tree, 'FootPersonalizationTaskList');
counter = 1;
footTasks = orderByIndex(tasks.FootPersonalizationTask);
for i=1:length(footTasks)
    if(length(footTasks) == 1)
        task = footTasks;
    else
        task = footTasks{i};
    end
    if(strcmpi(task.is_enabled.Text, 'true'))
        output{counter} = getFootData(task);
        output{counter} = getGroundReactions(inputs.bodyModel, ...
            inputs.grfFileName, output{counter});
        output{counter} = getMotionTime(inputs.bodyModel, ...
            inputs.motionFileName, output{counter});
        verifyTime(output{counter}.grfTime, output{counter}.time);
        tempFields = {'forceColumns', 'momentColumns', ...
            'electricalCenterColumns', 'grfTime', 'startTime', 'endTime'};
        output{counter} = rmfield(output{counter}, tempFields);
        counter = counter + 1;
    end
end
end

% (Model, string, struct) -> (struct)
% Determines the first and last included time point based on the input
% kinematics motion file and start and end times given for the foot. 
function task = getMotionTime(bodyModel, motionFile, task)
import org.opensim.modeling.Storage
[~, ikTime, ~] = parseMotToComponents(...
    Model(bodyModel), Storage(motionFile));
startIndex = find(ikTime >= task.startTime, 1, 'first');
endIndex = find(ikTime <= task.endTime, 1, 'last');
task.time = ikTime(startIndex:endIndex);
end

% (Model, string, struct) -> (struct)
% Parses ground reaction data from a file. This will throw an exception if
% any needed column is missing. 
function task = getGroundReactions(bodyModel, grfFile, task)
import org.opensim.modeling.Storage
[grfColumnNames, grfTime, grfData] = parseMotToComponents(...
    Model(bodyModel), Storage(grfFile));
startIndex = find(grfTime >= task.startTime, 1, 'first');
endIndex = find(grfTime <= task.endTime, 1, 'last');
task.grfTime = grfTime(startIndex:endIndex);
grf = NaN(3, length(task.grfTime));
moments = NaN(3, length(task.grfTime));
ec = NaN(3, length(task.grfTime));
for i=1:size(grfColumnNames')
    label = grfColumnNames(i);
    for j = 1:3
        if strcmpi(label, task.forceColumns(j, :))
            grf(j, :) = grfData(i, startIndex:endIndex);
        end
        if strcmpi(label, task.momentColumns(j, :))
            moments(j, :) = grfData(i, startIndex:endIndex);
        end
        if strcmpi(label, task.electricalCenterColumns(j, :))
            ec(j, :) = grfData(i, startIndex:endIndex);
        end
    end
end
if any([isnan(grf) isnan(moments) isnan(ec)])
    throw(MException('', ['Unable to parse GRF file, check that ' ...
        'all necessary column labels are present']))
end
task.experimentalGroundReactionForces = grf;
task.experimentalGroundReactionMoments = moments;
task.electricalCenter = ec;
end

% (struct, struct, struct) -> (struct)
% Gets foot-specific options directly included in XML file, including
% names of markers and ground reaction columns. 
function task = getFootData(tree)
    task.isLeftFoot = strcmpi('true', ...
        getFieldByNameOrError(tree, 'is_left_foot').Text);
    task.toesCoordinateName = getFieldByNameOrError(tree, ...
        'toe_coordinate').Text;
    task.markerNames.toe = getFieldByNameOrError(tree, ...
        'toe_marker').Text;
    task.markerNames.medial = getFieldByNameOrError(tree, ...
        'medial_marker').Text;
    task.markerNames.lateral = getFieldByNameOrError(tree, ...
        'lateral_marker').Text;
    task.markerNames.heel = getFieldByNameOrError(tree, ...
        'heel_marker').Text;
    task.markerNames.midfootSuperior = getFieldByNameOrError(tree, ...
        'midfoot_superior_marker').Text;
    task.startTime = str2double(getFieldByNameOrError(tree, ...
        'start_time').Text);
    task.endTime = str2double(getFieldByNameOrError(tree, ...
        'end_time').Text);
    task.beltSpeed = str2double(getFieldByNameOrError(tree, ...
        'belt_speed').Text);
    task.forceColumns = cell2mat(split(getFieldByNameOrError(tree, ...
        'force_columns').Text));
    task.momentColumns = cell2mat(split(getFieldByNameOrError(tree, ...
        'moment_columns').Text));
    task.electricalCenterColumns = cell2mat(split( ...
        getFieldByNameOrError(tree, 'electrical_center_columns').Text));
end

% (Array of double, Array of double) -> (None)
% Confirms that the time points from ground reaction and kinematics data
% match in length and value. 
function verifyTime(grfTime, ikTime)
    if size(ikTime) ~= size(grfTime)
        throw(MException('', ['IK and GRF time columns have ' ...
            'different lengths']))
    end
    if any(abs(ikTime - grfTime) > 0.005)
        throw(MException('', 'IK and GRF time points are not equal'))
    end
end

% Parses initial values.
function inputs = getInitialValues(inputs, tree)
inputs.initialRestingSpringLength = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(tree, 'initial_resting_spring_length', ...
    '0.05')));
inputs.initialSpringConstants = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(tree, 'initial_spring_constant', '2500')));
inputs.initialDampingFactor = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(tree, 'initial_damping_factor', '1e-4')));
inputs.initialDynamicFrictionCoefficient = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(tree, ...
    'initial_dynamic_friction_coefficient', '0')));
inputs.initialViscousFrictionCoefficient = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(tree, ...
    'initial_viscous_friction_coefficient', '5')));
end

% Gets single-value params.
function params = getParams(tree)
params = struct();
params.restingSpringLengthInitialization = strcmpi(getTextFromField( ...
    getFieldByNameOrAlternate(tree, ...
    'resting_spring_length_initialization_is_enabled', 'true')), 'true');
params.diffMinChange = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'diff_min_change', '1e-6')));
params.stepTolerance = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'step_tolerance', '1e-6')));
params.optimalityTolerance = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'optimality_tolerance', '1e-6')));
params.functionTolerance = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'function_tolerance', '1e-6')));
params.maxIterations = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'max_iterations', '400')));
params.maxFunctionEvaluations = str2double(getTextFromField(...
    getFieldByNameOrAlternate(tree, 'max_function_evaluations', ...
    '300000')));
params.tasks = getOptimizationTasks(tree);
end

% Gets cost terms and design variables included in each task.
function output = getOptimizationTasks(tree)
tasks = getFieldByNameOrError(tree, ...
    'GroundContactPersonalizationTaskList');
counter = 1;
gcpTasks = orderByIndex(tasks.GroundContactPersonalizationTask);
for i=1:length(gcpTasks)
    if(length(gcpTasks) == 1)
        task = gcpTasks;
    else
        task = gcpTasks{i};
    end
    if(strcmpi(task.is_enabled.Text, 'true'))
        output{counter} = getTaskDesignVariables(task);
        output{counter} = getTaskCostTerms( ...
            task.GroundContactCostFunctionTerms, output{counter});
        counter = counter + 1;
    end
end
end

% (struct) -> (struct)
function output = getTaskDesignVariables(tree)
variables = ["springConstants", "dampingFactor", ...
    "dynamicFrictionCoefficient", "viscousFrictionCoefficient", ...
    "restingSpringLength", "kinematicsBSplineCoefficients"];
for i=1:length(variables)
    output.designVariables(i) = strcmpi( ...
        tree.(variables(i)).Text, 'true');
end
end

% (struct, struct) -> (struct)
function taskStruct = getTaskCostTerms(tree, taskStruct)
costTermNames = ["markerPositionError", "markerSlopeError", ...
    "rotationError", "translationError", ...
    "coordinateCoefficientError", "verticalGrfError", ...
    "verticalGrfSlopeError", "horizontalGrfError", ...
    "horizontalGrfSlopeError", "groundReactionMomentError", ...
    "groundReactionMomentSlopeError", "springConstantErrorFromMean", ...
    "springConstantErrorFromNeighbors"];
for i = 1:length(costTermNames)
    costTermClassName = convertStringsToChars(costTermNames(i));
    costTermClassName = [upper(costTermClassName(1)) ...
        costTermClassName(2:end)];
    % If a cost term is not found in the XML file, assume it is not
    % enabled.
    enabled = valueOrAlternate(valueOrAlternate(tree, costTermClassName, ...
        'none'), 'is_enabled', 'false');
    if (isstruct(enabled))
        enabled = enabled.Text;
    end
    taskStruct.costTerms.(costTermNames(i)).isEnabled = strcmpi(...
        enabled, 'true');
    allowableError = valueOrAlternate(valueOrAlternate(tree, ...
        costTermClassName, 'none'), 'max_allowable_error', '1');
    if (isstruct(allowableError))
        allowableError = allowableError.Text;
    end
    taskStruct.costTerms.(costTermNames(i)).maxAllowableError = ...
        str2double(allowableError);
    % Only the term springConstantErrorFromNeighbors should have a standard
    % deviation element. 
    if costTermNames(i) == "springConstantErrorFromNeighbors"
        standardDeviation = valueOrAlternate(valueOrAlternate(tree, ...
            costTermClassName, 'none'), 'standard_deviation', '0.05');
        if (isstruct(standardDeviation))
            standardDeviation = standardDeviation.Text;
        end
        taskStruct.costTerms.(costTermNames(i)).standardDeviation = ...
            str2double(standardDeviation);
    end
end
end
