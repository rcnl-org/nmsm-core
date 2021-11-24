% This function is a wrapper for the JointModelPersonalization function
% such that an xml or osimx filename can be passed and the resulting
% computation can be completed according to the instructions of that file.

% Copyright RCNL *change later*

% (string) -> (None)
% Run JointModelPersonalization from settings file
function JointModelPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
% check arguments in advance to quit before computation if incorrect
outputFile = getOutputFile(settingsTree);

inputs = getInputs(settingsTree);
params = getParams(settingsTree);
newModel = JointModelPersonalization(inputs, params);
newModel.print(outputFile);
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

function output = getInputs(tree)
inputDirectory = getFieldByName(tree, 'input_directory').Text;
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
if(inputDirectory)
    output.model = fullfile(inputDirectory, modelFile);
else
    output.model = fullfile(pwd, modelFile);
    inputDirectory = pwd;
end
model = org.opensim.modeling.Model(output.model);
output.tasks = getTasks(model, tree, inputDirectory);
output.desiredError = ...
    str2num(getFieldByNameOrError(tree, 'desired_error').Text);
end

function output = getTasks(model, tree, inputDirectory)
    tasks = getFieldByNameOrError(tree, 'JointPersonalizationTaskList');
    counter = 1;
    for i=1:length(tasks.JointPersonalizationTask)
        if(length(tasks.JointPersonalizationTask) == 1)
            task = tasks.JointPersonalizationTask;
        else
            task = tasks.JointPersonalizationTask{i};
        end
        if(task.is_enabled.Text == 'true')
            output{counter} = getTask(model, ...
                task, inputDirectory);
            counter = counter + 1;
        end
    end
end

function output = getTask(model, tree, inputDirectory)
    output = applyIKSettingsParams(tree, inputDirectory);
    output.markerFile = fullfile(inputDirectory, ...
        tree.marker_file_name.Text);
    timeRange = getFieldByName(tree, 'time_range');
    if(isstruct(timeRange))
        timeRange = strsplit(timeRange.Text, ' ');
        output.startTime = str2double(timeRange{1});
        output.finishTime = str2double(timeRange{2});
    end
    output.parameters = getJointParameters(tree.Joint);%includes all joints
    translationBounds = getFieldByName(tree, 'translation_bounds');
    if(isstruct(translationBounds))
        translationBounds = str2double(translationBounds.Text);
    end
    orientationBounds = getFieldByName(tree, 'orientation_bounds');
    if(isstruct(orientationBounds))
        orientationBounds = str2double(orientationBounds.Text);
    end
    output.initialValues = getInitialValues(model, output.parameters);
    if(translationBounds || orientationBounds)
        [output.lowerBounds, output.upperBounds] = getBounds(...
            output.parameters, output.initialValues, ...
            translationBounds, orientationBounds);
    end
end

% this function is long and ugly but is a rote and imperative way to
% solve this problem, it's fine
function output = getJointParameters(jointTree)
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
            output{counter} = {jointName, true, true, j};
            counter = counter + 1;
        end
    end
    parentOrient = strsplit( ...
        joint.parent_frame_transformation.orientation.Text, ' ');
    verifyLength(parentOrient, 3);
    for j=0:2
        if(strcmp(parentOrient{j+1}, 'true'))
            output{counter} = {jointName, true, false, j};
            counter = counter + 1;
        end
    end
    childTrans = strsplit( ...
        joint.child_frame_transformation.translation.Text, ' ');
    verifyLength(childTrans, 3);
    for j=0:2
        if(strcmp(childTrans{j+1}, 'true'))
            output{counter} = {jointName, false, true, j};
            counter = counter + 1;
        end
    end
    childOrient = strsplit( ...
        joint.child_frame_transformation.orientation.Text, ' ');
    verifyLength(childOrient, 3);
    for j=0:2
        if(strcmp(childOrient{j+1},'true'))
            output{counter} = {jointName, false, false, j};
            counter = counter + 1;
        end
    end
end
end

function output = getInitialValues(model, parameters)
for i=1:length(parameters)
    temp = parameters{i};
    output(i) = getFrameParameterValue(model, temp{1}, ...
        temp{2}, temp{3}, temp{4});
end
end

function [lowerBounds, upperBounds] = getBounds(parameters, ...
    initialValues, translationBounds, orientationBounds)
for i=1:length(parameters)
    if(parameters{i}{3})
        lowerBounds(i) = initialValues(i) - translationBounds;
        upperBounds(i) = initialValues(i) + translationBounds;
    else
        lowerBounds(i) = initialValues(i) - orientationBounds;
        upperBounds(i) = initialValues(i) + orientationBounds;
    end
end
end

function output = applyIKSettingsParams(tree, inputDirectory)
import org.opensim.modeling.*
output = struct(); %incase no ik_settings_file
ikSettingsFile = getFieldByName(tree, 'ik_settings_file');
if(isstruct(ikSettingsFile))
    output.ikSettingsFile = fullfile(inputDirectory, ikSettingsFile.Text);
end
end

function output = getParams(tree)
import org.opensim.modeling.*
paramArgs = ["accuracy", "diff_min_change", "optimality_tolerance", ...
    "function_tolerance", "step_tolerance", "max_function_evaluations"];
for i=1:length(paramArgs)
    value = getFieldByName(tree, paramArgs(i));
    if(isstruct(value))
        output.(paramArgs(i)) = str2double(value.Text);
    end
end
end