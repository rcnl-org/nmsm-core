% This function is part of the NMSM Pipeline, see file for full license.
%
% Joint Model Personalization uses motion tracking data to personalize the
% joint locations and orientations of the model.
%
% (struct, struct) -> struct
% Runs the Joint Model Personalization algorithm

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

function outputModel = JointModelPersonalization(inputs, params)
verifyInputs(inputs);
verifyParams(params);
outputModel = Model(inputs.model);
for i=1:length(inputs.tasks)
    functions = makeFunctions(inputs.tasks{i}.parameters, ...
        inputs.tasks{i}.scaling, inputs.tasks{i}.markers, ...
        inputs.tasks{i}.anatomicalMarkers);
    [params.markerNames, params.markerAllowableErrors] = getMarkersInTask( ...
        outputModel, inputs.tasks{i});
    taskParams = mergeStructs(inputs.tasks{i}, params);
    outputModelFileName = saveTempOutputModel(inputs.modelFileName, ...
        outputModel);
    optimizedValues = computeKinematicCalibration(outputModelFileName, ...
        inputs.tasks{i}.markerFile, functions, inputs.desiredError, ...
        taskParams);
    outputModel = adjustModelFromOptimizerOutput( ...
        Model(outputModelFileName), functions, optimizedValues);
end
delete(outputModelFileName);
end

% (struct) -> (None)
% throws an error if any of the inputs are invalid
function verifyInputs(inputs)
try verifyModelArg(inputs.model); %check model args
catch; throw(MException('','inputs.model cannot instantiate a model'));end
try verifyNumeric(inputs.desiredError);
catch; throw(MException('','inputs.desiredError is not a number'));end
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
verifyParam(params, 'display', @verifyChar, ...
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

function outputModelFileName = saveTempOutputModel(modelFileName, ...
    outputModel)
[~,name,ext] = fileparts(modelFileName);
outputModelFileName = name + "_jmp_temp" + ext;
outputModel.finalizeConnections();
outputModel.print(outputModelFileName);
end

function functions = makeFunctions(...
    parameters, scaling, markers, anatomicalMarkers)
functions = {};
for i=1:length(parameters)
    p = parameters{i};
    functions{i} = makeJointFunction(p{1}, p{2}, p{3}, p{4});
end
for i=1:length(scaling)
    functions{end + 1} = makeScalingFunction( ...
        scaling(i), anatomicalMarkers);
end
for i=1:length(markers)
    marker = markers{i};
    name = marker(1);
    axis = marker(2);
    if strcmp(axis, "x")
        functions{end + 1} = makeMarkerFunction(name, "x");
    end
    if strcmp(axis, "y")
        functions{end + 1} = makeMarkerFunction(name, "y");
    end
    if strcmp(axis, "z")
        functions{end + 1} = makeMarkerFunction(name, "z");
    end
end
end

function [markerNames, markerAllowableErrors] = getMarkersInTask(model, task)
import org.opensim.modeling.*
if isfield(task, "markerNames")
    markerNames = task.markerNames;
    markerAllowableErrors = task.markerAllowableErrors;
    return
end
parameters = task.parameters;
bodies = task.scaling;
markerNames = {};
for i = 1:length(task.markers)
    if ~any(strcmp(markerNames, task.markers{i}(1)))
        markerNames{end+1} = convertStringsToChars(task.markers{i}(1));
    end
end
jointNames = {};
for i=1:length(parameters)
    if ~any(strcmp(jointNames,parameters{i}{1}))
        jointNames{length(jointNames)+1} = parameters{i}{1};
    end
end
for i = 1:length(bodies)
    joints = getBodyJointNames(model, bodies{i});
    for j = 1:length(joints)
        if ~any(strcmp(jointNames, joints(j)))
            jointNames{length(jointNames)+1} = joints(j);
        end
    end
end
for k=1:length(jointNames)
    newMarkerNames = getMarkersFromJoint(model, jointNames{k});
    for j=1:length(newMarkerNames)
        if(~markerIncluded(markerNames, newMarkerNames{j}))
            markerNames{length(markerNames)+1} = newMarkerNames{j};
        end
    end
end
end


