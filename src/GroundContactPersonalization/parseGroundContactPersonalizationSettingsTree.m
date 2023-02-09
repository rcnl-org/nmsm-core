% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct) -> (struct, struct, string)
% returns the input values for Ground Contact Personalization

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
inputDirectory = getFieldByName(tree, 'input_directory').Text;
inputs.bodyModel = getFieldByNameOrError(tree, 'input_model_file').Text;
inputs.model = getFieldByNameOrError(tree, 'input_foot_model_file').Text;
motionFile = getFieldByNameOrError(tree, 'input_motion_file').Text;
grfFile = getFieldByNameOrError(tree, 'input_grf_file').Text;
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
inputs.beltSpeed = str2double(getFieldByNameOrError(tree, ...
    'belt_speed').Text);

% Get inputs for each foot
inputs.tasks = getFootTasks(inputs, tree);
initialValuesTree = getFieldByNameOrError(tree, 'InitialValues');
inputs = getInitialValues(inputs, initialValuesTree);
end

% (struct, struct) -> (struct)
function output = getFootTasks(inputs, tree)
tasks = getFieldByNameOrError(tree, ...
    'FootPersonalizationTaskList');
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
        output{counter} = getMotion(inputs.bodyModel, ...
            inputs.motionFileName, output{counter});
        verifyTime(output{counter}.grfTime, output{counter}.time);
        output{counter}.splineNodes = valueOrAlternate(tree, ...
            'nodes_per_cycle', 25);
        if (isstruct(output{counter}.splineNodes))
            output{counter}.splineNodes = ...
                str2double(output{counter}.splineNodes.Text);
        end
        tempFields = {'forceColumns', 'momentColumns', ...
            'electricalCenterColumns', 'grfTime', 'startTime', 'endTime'};
        output{counter} = rmfield(output{counter}, tempFields);
        counter = counter + 1;
    end
end
end

% (Model, string, struct) -> (struct)
function task = getMotion(bodyModel, motionFile, task)
import org.opensim.modeling.Storage
[~, ikTime, ikData] = parseMotToComponents(...
    Model(bodyModel), Storage(motionFile));
startIndex = find(ikTime >= task.startTime, 1, 'first');
endIndex = find(ikTime <= task.endTime, 1, 'last');
task.time = ikTime(startIndex:endIndex);
task.motion = ikData(:, startIndex:endIndex);
end

% (Model, string, struct) -> (struct)
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
    if strcmpi(label, task.forceColumns(1, :))
        grf(1, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.forceColumns(2, :))
        grf(2, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.forceColumns(3, :))
        grf(3, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.momentColumns(1, :))
        moments(1, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.momentColumns(2, :))
        moments(2, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.momentColumns(3, :))
        moments(3, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.electricalCenterColumns(1, :))
        ec(1, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.electricalCenterColumns(2, :))
        ec(2, :) = grfData(i, startIndex:endIndex);
    end
    if strcmpi(label, task.electricalCenterColumns(3, :))
        ec(3, :) = grfData(i, startIndex:endIndex);
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
    task.forceColumns = cell2mat(split(getFieldByNameOrError(tree, ...
        'force_columns').Text));
    task.momentColumns = cell2mat(split(getFieldByNameOrError(tree, ...
        'moment_columns').Text));
    task.electricalCenterColumns = cell2mat(split( ...
        getFieldByNameOrError(tree, 'electrical_center_columns').Text));
end

% (Array of double, Array of double) -> (None)
function verifyTime(grfTime, ikTime)
    if size(ikTime) ~= size(grfTime)
        throw(MException('', ['IK and GRF time columns have ' ...
            'different lengths']))
    end
    if any(abs(ikTime - grfTime) > 0.005)
        throw(MException('', 'IK and GRF time points are not equal'))
    end
end

% Parses initial values
function inputs = getInitialValues(inputs, tree)
inputs.initialRestingSpringLength = str2double(getFieldByNameOrError(...
    tree, 'RestingSpringLength').Text);
inputs.initialSpringConstants = str2double(getFieldByNameOrError(...
    tree, 'SpringConstants').Text);
inputs.initialDampingFactor = str2double(getFieldByNameOrError(...
    tree, 'DampingFactor').Text);
inputs.initialDynamicFrictionCoefficient = str2double(...
    getFieldByNameOrError(tree, 'DynamicFrictionCoefficient').Text);
end

function params = getParams(tree)
params = struct();
params.maxIterations = valueOrAlternate(tree, 'max_iterations', 325);
if(isstruct(params.maxIterations))
    params.maxIterations = str2double(params.maxIterations.Text);
end
params.maxFunctionEvaluations = valueOrAlternate(tree, ...
    'max_function_evaluations', 3000000);
if(isstruct(params.maxFunctionEvaluations))
    params.maxFunctionEvaluations = str2double(params.maxFunctionEvaluations.Text);
end

params.tasks = getOptimizationTasks(tree);
end

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
        output{counter} = getTaskDesignVariables(task.DesignVariables);
        output{counter} = getTaskCostTerms(task.CostFunctionTerms, ...
            output{counter});
        counter = counter + 1;
    end
end
end

% (struct) -> (struct)
function output = getTaskDesignVariables(tree)
variables = ["springConstants", "dampingFactor", ...
    "dynamicFrictionCoefficient", "restingSpringLength", ...
    "kinematicsBSplineCoefficients"];
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
    enabled = valueOrAlternate(valueOrAlternate(tree, costTermNames(i), ...
        'none'), 'is_enabled', 'false');
    if (isstruct(enabled))
        enabled = enabled.Text;
    end
    taskStruct.costTerms.(costTermNames(i)).isEnabled = strcmpi(...
        enabled, 'true');
    allowableError = valueOrAlternate(valueOrAlternate(tree, ...
        costTermNames(i), 'none'), 'max_allowable_error', '1');
    if (isstruct(allowableError))
        allowableError = allowableError.Text;
    end
    taskStruct.costTerms.(costTermNames(i)).maxAllowableError = ...
        str2double(allowableError);
end
end
