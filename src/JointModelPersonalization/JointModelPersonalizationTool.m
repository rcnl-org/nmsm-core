% This function is a wrapper for the JointModelPersonalization function
% such that an xml or osimx filename can be passed and the resulting
% computation can be completed according to the instructions of that file.

% Copyright RCNL *change later*

% (string) -> (None)
% Run JointModelPersonalization from settings file
function JointModelPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName)
% check arguments in advance to quit before computation if incorrect
outputFile = getFieldByNameOrError(settingsTree, 'output_model_file').Text;
resultsDir = getFieldByNameOrError(settingsTree, 'results_directory').Text;
inputs = getInputs(settingsTree)
params = getParams(settingsTree)
newModel = JointModelPersonalization(inputs, params);
newModel.print(strcat(resultsDir,outputFile));
end

function output = getInputs(tree)
inputDirectory = getFieldByName(tree, 'input_directory').Text;
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
if(inputDirectory)
    output.model = strcat(inputDirectory, '\', modelFile);
else
    output.model = strcat(modelFile);
end
model = org.opensim.modeling.Model(output.model);
output.tasks = getTasks(model, tree, inputDirectory);
end

function output = getTasks(model, tree, inputDirectory)
    tasks = getFieldByNameOrError(tree, 'TaskSet');
    for i=1:length(tasks.Task)
        output{i} = getTask(model, tasks.Task{i}, inputDirectory);
    end
end

function output = getTask(model, tree, inputDirectory)
    output.markerFile = strcat(inputDirectory, '\', ...
        tree.marker_file_name.Text);
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
    parentTrans = strsplit(joint.parent_frame.translation.Text, ...
        ' ');
    verifyLength(parentTrans, 3);
    for j=0:2
        output{counter} = {jointName, true, true, j};
        counter = counter + 1;
    end
    parentOrient = strsplit(joint.parent_frame.orientation.Text, ...
        ' ');
    verifyLength(parentOrient, 3);
    for j=0:2
        output{counter} = {jointName, true, false, j};
        counter = counter + 1;
    end
    childTrans = strsplit(joint.child_frame.translation.Text, ' ');
    verifyLength(childTrans, 3);
    for j=0:2
        output{counter} = {jointName, false, true, j};
        counter = counter + 1;
    end
    childOrient = strsplit(joint.child_frame.orientation.Text, ' ');
    verifyLength(childOrient, 3);
    for j=0:2
        output{counter} = {jointName, false, false, j};
    end
end
end

function output = getInitialValues(model, parameters)
for i=1:length(parameters)
    temp = parameters{i};
    output(i) = getFrameCoordinateValue(model, temp{1}, ...
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

function output = getParams(tree)
paramArgs = ["accuracy", "diffMinChange", "optimalityTolerance", ...
    "functionTolerance", "stepTolerance", "maxFunctionEvaluations"];
for i=1:length(paramArgs)
    value = getFieldByName(tree, paramArgs(i));
    if(isstruct(value))
        output.(paramArgs(i)) = str2double(value.Text);
    end
end
end