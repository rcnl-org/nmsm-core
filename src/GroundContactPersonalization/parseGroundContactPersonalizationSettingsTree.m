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
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
motionFile = getFieldByNameOrError(tree, 'input_motion_file').Text;
grfFile = getFieldByNameOrError(tree, 'input_grf_file').Text;
if(~isempty(inputDirectory))
    try
        inputs.bodyModel = Model(fullfile(inputDirectory, modelFile));
        inputs.motionFileName = fullfile(inputDirectory, motionFile);
        inputs.grfFileName = fullfile(inputDirectory, grfFile);
    catch
        inputs.bodyModel = Model(fullfile(pwd, inputDirectory, modelFile));
        inputs.motionFileName = fullfile(pwd, inputDirectory, motionFile);
        inputs.grfFileName = fullfile(pwd, inputDirectory, grfFile);
        inputDirectory = fullfile(pwd, inputDirectory);
    end
else
    inputs.bodyModel = Model(fullfile(pwd, modelFile));
    inputs.motionFileName = fullfile(pwd, motionFile);
    inputs.grfFileName = fullfile(pwd, grfFile);
    inputDirectory = pwd;
end
inputs.numberCycles = getFieldByNameOrError(tree, 'number_of_cycles');
inputs.nodesPerCycle = getFieldByNameOrError(tree, 'nodes_per_cycle');
rightTree = getFieldByNameOrError(tree, 'RightFootPersonalization');
leftTree = getFieldByNameOrError(tree, 'LeftFootPersonalization');
inputs.right.isEnabled = strcmpi(getFieldByNameOrError(rightTree, ...
    'is_enabled').Text, 'true');
inputs.left.isEnabled = strcmpi(getFieldByNameOrError(leftTree, ...
    'is_enabled').Text, 'true');
[ik.columnNames, ik.time, ik.data] = parseMotToComponents(...
    inputs.bodyModel, Storage(inputs.grfFileName));
[~, grfTime, ~] = parseMotToComponents(...
    inputs.bodyModel, Storage(inputs.grfFileName));
verifyTime(ik.time, grfTime);
[inputs.left.experimentalGroundReactionForces, ...
    inputs.right.experimentalGroundReactionForces] = getGrf(...
    inputs.bodyModel, inputs.grfFileName);

if inputs.right.isEnabled
    inputs.right = getInputsForSide(inputs.right, rightTree, ik);
end
if inputs.left.isEnabled
    inputs.left = getInputsForSide(inputs.left, leftTree, ik);
end
inputs.errorCenters.markerDistanceError = getFieldByNameOrError(tree, ...
    'marker_distance_error');
inputs.errorCenters.staticFrictionCoefficient = getFieldByNameOrError(...
    tree, 'static_friction_coefficient');
inputs.errorCenters.dynamicFrictionCoefficient = getFieldByNameOrError(...
    tree, 'dynamic_friction_coefficient');
inputs.errorCenters.viscousFrictionCoefficient = getFieldByNameOrError(...
    tree, 'viscous_friction_coefficient');
end

% (Model, string) -> (Array of double, Array of double)
function [grfLeft, grfRight] = getGrf(bodyModel, grfFile)
import org.opensim.modeling.Storage
storage = Storage(grfFile);
[grfColumnNames, ~, grfData] = parseMotToComponents(bodyModel, ...
    Storage(grfFileName));
grfLeft = NaN(3, storage.getSize());
grfRight = NaN(3, storage.getSize());
for i=1:size(grfColumnNames)
    label = grfColumnNames(i);
    if contains(label, 'F')
        if contains(label, '1') && contains(label, 'x')
            grfLeft(1, :) = grfData(i, :);
        end
        if contains(label, '1') && contains(label, 'y')
            grfLeft(2, :) = grfData(i, :);
        end
        if contains(label, '1') && contains(label, 'z')
            grfLeft(3, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'x')
            grfRight(1, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'y')
            grfRight(2, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'z')
            grfRight(3, :) = grfData(i, :);
        end
    end
end
if any(isnan(grfLeft)) || any(isnan(grfRight))
    throw(MException('', ['Unable to parse GRF file, check that ' ...
        'all necessary column labels are present']))
end
end

% (struct, struct, struct) -> (struct)
function inputs = getInputsForSide(inputs, tree, ik)
    inputs.toesCoordinateName = getFieldByNameOrError(tree, ...
        'toe_coordinate').Text;
    inputs.startTime = getFieldByNameOrError(tree, 'start_time');
    inputs.endTime = getFieldByNameOrError(tree, 'end_time');
    startIndex = find(ik.time >= inputs.startTime, 1, 'first');
    endIndex = find(ik.time <= inputs.endTime, 1, 'last');
    inputs.time = ik.time(startIndex:endIndex);
    inputs.motion = ik.data(:, startIndex:endIndex);
    inputs.grf = inputs.grf(:, startIndex:endIndex);
end

% (Array of double, Array of double) -> (None)
function verifyTime(ikTime, grfTime)
    if size(ikTime) ~= size(grfTime)
        throw(MException('', ['IK and GRF time columns have' ...
            'different lengths']))
    end
    if any(abs(ikTime - grfTime) > 0.005)
        throw(MException('', ['IK and GRF time points are not equal']))
    end
end

function params = getParams(tree)
params = struct();
maxIterations = getFieldByName(tree, 'max_iterations');
if(isstruct(maxIterations))
    params.maxIterations = str2double(maxIterations.Text);
end
maxFunctionEvaluations = getFieldByName(tree, 'max_function_evaluations');
if(isstruct(maxFunctionEvaluations))
    params.maxFunctionEvaluations = str2double(maxFunctionEvaluations.Text);
end
end