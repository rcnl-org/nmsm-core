% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Joint Model Personalization Settings XML file.
%
% (struct) -> (string, struct, struct)
% returns the input values for Joint Model Personalization

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

function [outputFile, inputs, params] = ...
    parseJointModelPersonalizationSettingsTree(settingsTree)
% check arguments in advance to quit before computation if incorrect
outputFile = getOutputFile(settingsTree);
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
end

function outputFile = getOutputFile(tree)
outputFile = getFieldByNameOrError(tree, 'output_model_file').Text;
resultsDir = getFieldByNameOrError(tree, 'results_directory').Text;
if(resultsDir)
    outputFile = fullfile(resultsDir, outputFile);
else
    outputFile = fullfile(pwd, outputFile);
end
end

function inputs = getInputs(tree)
inputs.model = parseModel(tree);
model = Model(inputs.model);
inputs.tasks = getTasks(model, tree);
inputs.desiredError = ...
    str2num(getFieldByNameOrError(tree, 'desired_error').Text);
end

function inputs = getTasks(model, tree)
tasks = getFieldByNameOrError(tree, 'JMPTaskList');
counter = 1;
jmpTasks = orderByIndex(tasks.JMPTask);
for i=1:length(jmpTasks)
    if(length(jmpTasks) == 1)
        task = jmpTasks;
    else
        task = jmpTasks{i};
    end
    if(task.is_enabled.Text == 'true')
        inputs{counter} = getTask(model, task);
        counter = counter + 1;
    end
end
end

function output = getTask(model, tree)
output.markerFile = tree.marker_file_name.Text;
timeRange = getFieldByName(tree, 'time_range');
if(isstruct(timeRange))
    timeRange = strsplit(timeRange.Text, ' ');
    output.startTime = str2double(timeRange{1});
    output.finishTime = str2double(timeRange{2});
end
output.parameters = {};
if(isstruct(getFieldByName(tree, "JMPJointSet")) || ...
        iscell(getFieldByName(tree, "JMPJointSet")))
    output.parameters = getJointParameters(tree.JMPJointSet);
end
output.scaling = [];
output.markers = [];
if(isstruct(getFieldByName(tree, "JMPBodySet")) || ...
        iscell(getFieldByName(tree, "JMPBodySet")))
    [output.scaling, output.markers] = ...
        getBodyParameters(tree.JMPBodySet, model);
end
translationBounds = getFieldByName(tree, 'translation_bounds');
if(isstruct(translationBounds))
    translationBounds = str2double(translationBounds.Text);
end
orientationBounds = getFieldByName(tree, 'orientation_bounds');
if(isstruct(orientationBounds))
    orientationBounds = str2double(orientationBounds.Text);
end
output.initialValues = getInitialValues(model, output.parameters, ...
    output.scaling, output.markers);
if(translationBounds || orientationBounds)
    [output.lowerBounds, output.upperBounds] = getBounds(...
        output.parameters, output.initialValues, ...
        translationBounds, orientationBounds, output.scaling, ...
        output.markers);
end
end

% this function is long and ugly but is a rote and imperative way to
% solve this problem, it's fine
function inputs = getJointParameters(jointSetTree)
jointTree = getFieldByNameOrError(jointSetTree, "JMPJoint");
counter = 1; % for index of parameter in output
for i=1:length(jointTree)
    if(length(jointTree) == 1)
        joint = jointTree;
    else
        joint = jointTree{i};
    end
    jointName = joint.Attributes.name;
    parentTrans = strsplit( ...
        joint.parent_frame_transformation.translation.Text, ' ');
    verifyLength(parentTrans, 3);
    for j=0:2
        if(strcmp(parentTrans{j+1}, 'true'))
            inputs{counter} = {jointName, true, true, j};
            counter = counter + 1;
        end
    end
    parentOrient = strsplit( ...
        joint.parent_frame_transformation.orientation.Text, ' ');
    verifyLength(parentOrient, 3);
    for j=0:2
        if(strcmp(parentOrient{j+1}, 'true'))
            inputs{counter} = {jointName, true, false, j};
            counter = counter + 1;
        end
    end
    childTrans = strsplit( ...
        joint.child_frame_transformation.translation.Text, ' ');
    verifyLength(childTrans, 3);
    for j=0:2
        if(strcmp(childTrans{j+1}, 'true'))
            inputs{counter} = {jointName, false, true, j};
            counter = counter + 1;
        end
    end
    childOrient = strsplit( ...
        joint.child_frame_transformation.orientation.Text, ' ');
    verifyLength(childOrient, 3);
    for j=0:2
        if(strcmp(childOrient{j+1},'true'))
            inputs{counter} = {jointName, false, false, j};
            counter = counter + 1;
        end
    end
end
end

function [scaling, markers] = getBodyParameters( ...
    bodySetTree, model)
scaling = getScalingBodies(bodySetTree);
markers = getMarkers(bodySetTree, model);
end

function output = getScalingBodies(bodySetTree)
bodyTree = getFieldByNameOrError(bodySetTree, "JMPBody");
output = string([]);
for i=1:length(bodyTree)
    if(length(bodyTree) == 1)
        body = bodyTree;
    else
        body = bodyTree{i};
    end
    bodyName = body.Attributes.name;
    scaleBodies = strcmp(getFieldByNameOrError(body, ...
        "scale_body").Text, "true");
    if(scaleBodies)
        output(end + 1) = bodyName;
    end
end
end

function output = getMarkers(bodySetTree, model)
bodyTree = getFieldByNameOrError(bodySetTree, "JMPBody");
    axesNames = ["x", "y", "z"];
output = {};
for i=1:length(bodyTree)
    if(length(bodyTree) == 1)
        body = bodyTree;
    else
        body = bodyTree{i};
    end
    bodyName = body.Attributes.name;
    axesStrings = parseSpaceSeparatedList(body, "move_markers");
    axes = zeros(1, 3);
    for j = 1:3
        axes(j) = axesStrings(j) == "true";
    end
    if(axes(1) || axes(2) || axes(3))
        markers = getMarkersFromBody(model, bodyName);
        for j = 1:length(markers)
            for k = 1:3
                if(axes(k))
                    output{end + 1} = [markers(j), axesNames(k)];
                end
            end
        end
    end
end
end

function output = getInitialValues(model, parameters, scaling, markers)
for i = 1 : length(parameters)
    temp = parameters{i};
    output(i) = getFrameParameterValue(model, temp{1}, ...
        temp{2}, temp{3}, temp{4});
end
for i = 1 : length(scaling)
    output(end + 1) = getScalingParameterValue(model, scaling(i));
end
for i = 1 : length(markers)
    marker = markers{i};
    [xPosition, yPosition, zPosition] = getMarkerParameterValues( ...
        model, marker(1));
    axis = marker(2);
    if ~strcmp(axis, "x") output(end + 1) = xPosition; end
    if ~strcmp(axis, "y") output(end + 1) = yPosition; end
    if ~strcmp(axis, "z") output(end + 1) = zPosition; end
end
end

function [lowerBounds, upperBounds] = getBounds(parameters, ...
    initialValues, translationBounds, orientationBounds, scaling, markers)
for i=1:length(parameters)
    if(parameters{i}{3})
        lowerBounds(i) = initialValues(i) - translationBounds;
        upperBounds(i) = initialValues(i) + translationBounds;
    else
        lowerBounds(i) = initialValues(i) - orientationBounds;
        upperBounds(i) = initialValues(i) + orientationBounds;
    end
end
for i = 1 : length(scaling)
    lowerBounds(end + 1) = -Inf;
    upperBounds(end + 1) = Inf;
end
for i = 1 : length(markers) % double values for X and Z directions
    lowerBounds(end + 1) = -Inf;
    lowerBounds(end + 1) = -Inf;
    upperBounds(end + 1) = Inf;
    upperBounds(end + 1) = Inf;
end
end

function output = getParams(tree)
import org.opensim.modeling.*
paramArgs = ["accuracy", "diff_min_change", "optimality_tolerance", ...
    "function_tolerance", "step_tolerance", "max_function_evaluations"];
% name in matlab is different, use for output struct arg name
paramName = ["accuracy", "diffMinChange", "optimalityTolerance", ...
    "functionTolerance", "stepTolerance", "maxFunctionEvaluations"];
for i=1:length(paramArgs)
    value = getFieldByName(tree, paramArgs(i));
    if(isstruct(value))
        output.(paramName(i)) = str2double(value.Text);
    end
end
end