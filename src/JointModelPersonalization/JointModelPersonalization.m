% Joint Model Personalization uses motion tracking data to personalize the
% joint locations and orientations of the model.

% Copyright RCNL *change to actual license in future*

% (struct, struct) -> struct
% Runs the Joint Model Personalization algorithm
function outputModel = JointModelPersonalization(inputs, params)
import org.opensim.modeling.*
verifyInputs(inputs);
verifyParams(params);
outputModel = Model(inputs.model); %copy model
for i=1:length(inputs.tasks)
    functions = makeFunctions(inputs.tasks{i}.parameters);
    taskParams = mergeStructs(inputs.tasks{i}, params);
    optimizedValues = computeKinematicCalibration(inputs.model, ...
        inputs.tasks{i}.markerFile, functions, taskParams);
    outputModel = adjustModelFromOptimizerOutput(outputModel, ...
        functions, optimizedValues);
end
end

% (struct) -> (None)
% throws an error if any of the inputs are invalid
function verifyInputs(inputs)
try verifyModelArg(inputs.model); %check model args
catch; throw(MException('','inputs.model cannot instantiate a model'));end

for i=1:length(inputs.tasks)
    % check marker files
    try verifyMarkersReferenceArg(inputs.tasks{i}.markerFile); 
    catch; throw(MException('',strcat('invalid markerFile for task ', ...
            num2str(i))));
    end
    % check function params
    try verifyJointModelPersonalizationFunctionsArgs(...
            inputs.model, inputs.tasks{i}.parameters);
    catch; throw(MException('', strcat('invalid function parameters ', ...
            'for task ', num2str(i)))); 
    end
end
end

% (struct) -> (None)
% throws an error if the parameter is included but is not of valid type
function verifyParams(params)
verifyParam(params, 'accuracy', @verifyNumeric, ...
    'param ikSolverAccuracy is not a number');
verifyParam(params, 'diffMinChange', @verifyNumeric, ...
    'param diffMinChange is not a number');
verifyParam(params, 'optimalityTolerance', @verifyNumeric, ...
    'param optimalityTolerance is not a number');
verifyParam(params, 'functionTolerance', @verifyNumeric, ...
    'param functionTolerance is not a number');
verifyParam(params, 'stepTolerance', @verifyNumeric, ...
    'param stepTolerance is not a number');
verifyParam(params, 'maxFunctionEvaluations', @verifyNumeric, ...
    'param maxFunctionEvaluations is not a number');
verifyParam(params, 'sisplay', @verifyChar, ...
    'param display is not a char');
end

% (struct, string, function, string) -> (None)
% checks if field exists, runs verification, throws error with message
function verifyParam(params, fieldName, fn, message)
if(isfield(params, fieldName))
    try fn(params.(fieldName));
    catch; throw(MException('', message));
    end
end
end

function functions = makeFunctions(parameters)
functions = {};
for i=1:length(parameters)
    p = parameters{i};
    functions{i} = makeJointFunction(p{1}, p{2}, p{3}, p{4});
end
end