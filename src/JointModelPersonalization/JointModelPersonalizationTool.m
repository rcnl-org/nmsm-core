% This function is a wrapper for the JointModelPersonalization function
% such that an xml or osimx filename can be passed and the resulting
% computation can be completed according to the instructions of that file.

% Copyright RCNL *change later*

% (string) -> (None)
% Run JointModelPersonalization from settings file
function JointModelPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
% check arguments in advance to quit before computation if incorrect
outputFile = getFieldByNameOrError(settingsTree, 'output_model_file').Text;
resultsDir = getFieldByNameOrError(settingsTree, 'results_directory').Text;
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
newModel = JointModelPersonalization(inputs, params);
newModel.print(strcat(pwd,outputFile))
end

function output = getInputs(tree)
inputDirectory = getFieldByName('input_directory');
modelFile = getFieldByNameOrError("input_model_file");
if(inputDirectory)
    output.model = strcat(input, modelFile);
else
    output.model = modelFile;
end
model = org.opensim.modeling.Model(output.model);
output.tasks = getTasks(model, tree);
end

function output = getTasks(model, tree)
    tasks = getFieldByNameOrError(tree, 'TaskSet');
    for i=1:length(tasks.Task)
        output{i} = getTask(model, tasks.Task{i});
    end
end

function output = getTask(model, tree)
    output.markerFile = tree.marker_file_name;
    output.parameters = getJointParameters(tree.Joint)
    translationBounds = str2double(getFieldByName('translation_bounds'));
    orientationBounds = str2double(getFieldByName('orientation_bounds'));
    output.initialValues = getInitialValues(model, output.parameters);
    if(translationBounds || orientationBounds)
        [output.lowerBounds, output.upperBounds] = getBounds(...
            output.parameters, output.initialValues, ...
            translationBounds, orientationBounds);
    end
end

function output = getJointParameters(tree)

end

function output = getInitialValues(model, parameters)

end

function [lowerBounds, upperBounds] = getBounds(parameters, ...
    initialValues, translationBounds, orientationBounds)
for i=1:length(parameters)
    if(parameters{3})
        lowerBounds(i) = initialValues - translationBounds;
        upperBounds(i) = initialValues + translationBounds;
    else
        lowerBounds(i) = initialValues - orientationBounds;
        upperBounds(i) = initialValues + orientationBounds;
    end
end
end
function output = getParams(tree)
paramArgs = ["accuracy","diffMinChange", "optimalityTolerance", ...
    "functionTolerance", "stepTolerance", "maxFunctionEvaluations"];
for i=1:length(paramArgs)
    value = getFieldByName(tree, paramArgs(i));
    if(value)
        output.(paramArgs(i)) = value;
    end
end
end