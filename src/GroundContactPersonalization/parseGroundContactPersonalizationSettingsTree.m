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
inputs.numberCycles = str2double(getFieldByNameOrError(tree, ...
    'number_of_cycles').Text);
inputs.nodesPerCycle = str2double(getFieldByNameOrError(tree, ...
    'nodes_per_cycle').Text);
inputs.beltSpeed = str2double(getFieldByNameOrError(tree, ...
    'belt_speed').Text);
rightTree = getFieldByNameOrError(tree, 'RightFootPersonalization');
leftTree = getFieldByNameOrError(tree, 'LeftFootPersonalization');
inputs.right.isEnabled = strcmpi(getFieldByNameOrError(rightTree, ...
    'is_enabled').Text, 'true');
inputs.left.isEnabled = strcmpi(getFieldByNameOrError(leftTree, ...
    'is_enabled').Text, 'true');
[ik.columnNames, ik.time, ik.data] = parseMotToComponents(...
    bodyModel, Storage(inputs.grfFileName));
[~, grfTime, ~] = parseMotToComponents(...
    bodyModel, Storage(inputs.grfFileName));
verifyTime(ik.time, grfTime);
[inputs.left.experimentalGroundReactionForces, ...
    inputs.right.experimentalGroundReactionForces] = getGrf(...
    bodyModel, inputs.grfFileName);
[inputs.left.experimentalGroundReactionMoments, ...
    inputs.right.experimentalGroundReactionMoments] = getMoments(...
    bodyModel, inputs.grfFileName);
[inputs.left.electricalCenter, inputs.right.electricalCenter] = ...
    getElectricalCenter(bodyModel, inputs.grfFileName);

if inputs.right.isEnabled
    % Potentially refactor to use inputs.right if allowing multiple sides
    inputs = getInputsForSide(inputs, rightTree, ik);
end
if inputs.left.isEnabled
    inputs.isLeftFoot = true;
    inputs.left = getInputsForSide(inputs.left, leftTree, ik);
end

initialValuesTree = getFieldByNameOrError(tree, 'InitialValues');
inputs = getInitialValues(inputs, initialValuesTree);
end

% (Model, string) -> (Array of double, Array of double)
function [grfLeft, grfRight] = getGrf(bodyModel, grfFile)
import org.opensim.modeling.Storage
storage = Storage(grfFile);
[grfColumnNames, ~, grfData] = parseMotToComponents(bodyModel, ...
    Storage(grfFile));
grfLeft = NaN(3, storage.getSize());
grfRight = NaN(3, storage.getSize());
for i=1:size(grfColumnNames')
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
if any([isnan(grfLeft) isnan(grfRight)])
    throw(MException('', ['Unable to parse GRF file, check that ' ...
        'all necessary column labels are present']))
end
end

% (Model, string) -> (Array of double, Array of double)
function [momentsLeft, momentsRight] = getMoments(bodyModel, grfFile)
import org.opensim.modeling.Storage
storage = Storage(grfFile);
[grfColumnNames, ~, grfData] = parseMotToComponents(bodyModel, ...
    Storage(grfFile));
momentsLeft = NaN(3, storage.getSize());
momentsRight = NaN(3, storage.getSize());
for i=1:size(grfColumnNames')
    label = grfColumnNames(i);
    if contains(label, 'M')
        if contains(label, '1') && contains(label, 'x')
            momentsLeft(1, :) = grfData(i, :);
        end
        if contains(label, '1') && contains(label, 'y')
            momentsLeft(2, :) = grfData(i, :);
        end
        if contains(label, '1') && contains(label, 'z')
            momentsLeft(3, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'x')
            momentsRight(1, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'y')
            momentsRight(2, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'z')
            momentsRight(3, :) = grfData(i, :);
        end
    end
end
if any([isnan(momentsLeft) isnan(momentsRight)])
    throw(MException('', ['Unable to parse GRF file, check that ' ...
        'all necessary column labels are present']))
end
end

% (Model, string) -> (Array of double, Array of double)
function [electricalCenterLeft, electricalCenterRight] = ...
    getElectricalCenter(bodyModel, grfFile)
import org.opensim.modeling.Storage
storage = Storage(grfFile);
[grfColumnNames, ~, grfData] = parseMotToComponents(bodyModel, ...
    Storage(grfFile));
electricalCenterLeft = NaN(3, storage.getSize());
electricalCenterRight = NaN(3, storage.getSize());
for i=1:size(grfColumnNames')
    label = grfColumnNames(i);
    if contains(label, 'EC')
        if contains(label, '1') && contains(label, 'x')
            electricalCenterLeft(1, :) = grfData(i, :);
        end
        if contains(label, '1') && contains(label, 'y')
            electricalCenterLeft(2, :) = grfData(i, :);
        end
        if contains(label, '1') && contains(label, 'z')
            electricalCenterLeft(3, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'x')
            electricalCenterRight(1, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'y')
            electricalCenterRight(2, :) = grfData(i, :);
        end
        if contains(label, '2') && contains(label, 'z')
            electricalCenterRight(3, :) = grfData(i, :);
        end
    end
end
if any([isnan(electricalCenterLeft) isnan(electricalCenterRight)])
    throw(MException('', ['Unable to parse GRF file, check that ' ...
        'all necessary column labels are present']))
end
end

% (struct, struct, struct) -> (struct)
function inputs = getInputsForSide(inputs, tree, ik)
    inputs.toesCoordinateName = getFieldByNameOrError(tree, ...
        'toe_coordinate').Text;
    inputs.markerNames.toe = getFieldByNameOrError(tree, ...
        'toe_marker').Text;
    inputs.markerNames.medial = getFieldByNameOrError(tree, ...
        'medial_marker').Text;
    inputs.markerNames.lateral = getFieldByNameOrError(tree, ...
        'lateral_marker').Text;
    inputs.markerNames.heel = getFieldByNameOrError(tree, ...
        'heel_marker').Text;
    inputs.startTime = str2double(getFieldByNameOrError(tree, ...
        'start_time').Text);
    inputs.endTime = str2double(getFieldByNameOrError(tree, ...
        'end_time').Text);
    startIndex = find(ik.time >= inputs.startTime, 1, 'first');
    endIndex = find(ik.time <= inputs.endTime, 1, 'last');
    inputs.time = ik.time(startIndex:endIndex);
    inputs.motion = ik.data(:, startIndex:endIndex);
    % Refactor second lines to inputs.experimentalGRF, etc if allowing multiple sides
    inputs.experimentalGroundReactionForces = ...
        inputs.right.experimentalGroundReactionForces(:, startIndex:endIndex);
    inputs.experimentalGroundReactionMoments = ...
        inputs.right.experimentalGroundReactionMoments(:, startIndex:endIndex);
    inputs.electricalCenter = ...
        inputs.right.electricalCenter(:, startIndex:endIndex);
end

% (Array of double, Array of double) -> (None)
function verifyTime(ikTime, grfTime)
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
inputs.initialDampingFactors = str2double(getFieldByNameOrError(...
    tree, 'DampingFactors').Text);
inputs.initialDynamicFrictionCoefficient = str2double(...
    getFieldByNameOrError(tree, 'DynamicFrictionCoefficient').Text);
end

function params = getParams(tree)
params = struct();
params.maxIterations = getFieldByName(tree, 'max_iterations');
if(isstruct(params.maxIterations))
    params.maxIterations = str2double(params.maxIterations.Text);
end
params.maxFunctionEvaluations = getFieldByName(tree, 'max_function_evaluations');
if(isstruct(params.maxFunctionEvaluations))
    params.maxFunctionEvaluations = str2double(params.maxFunctionEvaluations.Text);
end
params = getDesignVariableParams(params, tree);
params = getCostFunctionParams(params, tree);
end

function params = getDesignVariableParams(params, tree)
% Stage 1 design variables
stageOneTree = getFieldByNameOrError(tree, 'Stage1DesignVariables');
params.stageOne.springConstants.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageOneTree, ...
    'SpringConstants'), 'is_enabled').Text, 'true');
params.stageOne.dampingFactors.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageOneTree, ...
    'DampingFactors'), 'is_enabled').Text, 'true');
params.stageOne.bSplineCoefficients.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageOneTree, ...
    'KinematicsBSplineCoefficients'), 'is_enabled').Text, 'true');
% Stage 2 design variables
stageTwoTree = getFieldByNameOrError(tree, 'Stage2DesignVariables');
params.stageTwo.springConstants.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageTwoTree, ...
    'SpringConstants'), 'is_enabled').Text, 'true');
params.stageTwo.dampingFactors.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageTwoTree, ...
    'DampingFactors'), 'is_enabled').Text, 'true');
params.stageTwo.bSplineCoefficients.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageTwoTree, ...
    'KinematicsBSplineCoefficients'), 'is_enabled').Text, 'true');
params.stageTwo.dynamicFrictionCoefficient.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageTwoTree, ...
    'DynamicFrictionCoefficient'), 'is_enabled').Text, 'true');
% Stage 3 design variables
stageThreeTree = getFieldByNameOrError(tree, 'Stage2DesignVariables');
params.stageThree.springConstants.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageThreeTree, ...
    'SpringConstants'), 'is_enabled').Text, 'true');
params.stageThree.dampingFactors.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageThreeTree, ...
    'DampingFactors'), 'is_enabled').Text, 'true');
params.stageThree.bSplineCoefficients.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageThreeTree, ...
    'KinematicsBSplineCoefficients'), 'is_enabled').Text, 'true');
params.stageThree.dynamicFrictionCoefficient.isEnabled = strcmpi(...
    getFieldByNameOrError(getFieldByNameOrError(stageThreeTree, ...
    'DynamicFrictionCoefficient'), 'is_enabled').Text, 'true');
end

function params = getCostFunctionParams(params, tree)
stageOneTree = getFieldByNameOrError(tree, 'Stage1CostFunctionTerms');
stageOneCostTerms = ["markerPositionError", "markerSlopeError", ...
    "verticalGrfError", "verticalGrfSlopeError", ...
    "springConstantErrorFromMean", "dampingFactorErrorFromMean"];
for i = 1:length(stageOneCostTerms)
    params.stageOneCosts.(stageOneCostTerms(i)).isEnabled = strcmpi(...
        getFieldByNameOrError(getFieldByNameOrError(stageOneTree, ...
        stageOneCostTerms(i)), 'is_enabled').Text, 'true');
    params.stageOneCosts.(stageOneCostTerms(i)).maxAllowableError = str2double(...
        getFieldByNameOrError(getFieldByNameOrError(stageOneTree, ...
        stageOneCostTerms(i)), 'max_allowable_error').Text);
end

stageTwoTree = getFieldByNameOrError(tree, 'Stage2CostFunctionTerms');
stageTwoCostTerms = ["markerPositionError", "markerSlopeError", ...
    "verticalGrfError", "verticalGrfSlopeError", "horizontalGrfError", ...
    "horizontalGrfSlopeError", "springConstantErrorFromMean", ...
    "dampingFactorErrorFromMean"];
for i = 1:length(stageTwoCostTerms)
    params.stageTwoCosts.(stageTwoCostTerms(i)).isEnabled = strcmpi(...
        getFieldByNameOrError(getFieldByNameOrError(stageTwoTree, ...
        stageTwoCostTerms(i)), 'is_enabled').Text, 'true');
    params.stageTwoCosts.(stageTwoCostTerms(i)).maxAllowableError = str2double(...
        getFieldByNameOrError(getFieldByNameOrError(stageTwoTree, ...
        stageTwoCostTerms(i)), 'max_allowable_error').Text);
end

stageThreeTree = getFieldByNameOrError(tree, 'Stage2CostFunctionTerms');
stageThreeCostTerms = ["markerPositionError", "markerSlopeError", ...
    "coordinateCoefficientError", "verticalGrfError", ...
    "verticalGrfSlopeError", "horizontalGrfError", ...
    "horizontalGrfSlopeError", "groundReactionMomentError", ...
    "groundReactionMomentSlopeError", "springConstantErrorFromMean", ...
    "dampingFactorErrorFromMean"];
for i = 1:length(stageThreeCostTerms)
    params.stageThreeCosts.(stageThreeCostTerms(i)).isEnabled = strcmpi(...
        getFieldByNameOrError(getFieldByNameOrError(stageThreeTree, ...
        stageThreeCostTerms(i)), 'is_enabled').Text, 'true');
    params.stageThreeCosts.(stageThreeCostTerms(i)).maxAllowableError = str2double(...
        getFieldByNameOrError(getFieldByNameOrError(stageThreeTree, ...
        stageThreeCostTerms(i)), 'max_allowable_error').Text);
end
end