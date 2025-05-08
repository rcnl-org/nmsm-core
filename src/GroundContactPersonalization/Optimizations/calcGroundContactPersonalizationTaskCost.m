% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, Array of string, struct, struct, double) -> (Array of double)
% Calculate cost for a Ground Contact Personalization task. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Claire V. Hammond                          %
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

function cost = calcGroundContactPersonalizationTaskCost( ...
    values, fieldNameOrder, inputs, params, task)
% OpenSim models are non-serializable objects, so they cannot normally be
% passed to a parallel pool. Using a persistent variable, the models are
% opened once per parallel worker and repeatedly accessed. 
persistent models;
for foot = 1:length(inputs.surfaces)
    if ~isfield(models, "model_" + foot)
        models.("model_" + foot) = Model(inputs.surfaces{foot}.model);
    end
end
valuesStruct = unpackValues(values, inputs, fieldNameOrder);
% If a design variable is not included, its static value from inputs is
% added to valuesStruct so it can be used to calculate cost if needed. 
if ~params.tasks{task}.designVariables(1)
        valuesStruct.springConstants = inputs.springConstants;
end
if ~params.tasks{task}.designVariables(2)
        valuesStruct.dampingFactor = inputs.dampingFactor;
end
if ~params.tasks{task}.designVariables(3)
        valuesStruct.dynamicFrictionCoefficient = ...
            inputs.dynamicFrictionCoefficient;
end
if ~params.tasks{task}.designVariables(4)
        valuesStruct.viscousFrictionCoefficient = ...
            inputs.viscousFrictionCoefficient;
end
if ~params.tasks{task}.designVariables(5)
        valuesStruct.restingSpringLength = ...
            inputs.restingSpringLength;
end
if ~params.tasks{task}.designVariables(6)
    for foot = 1:length(inputs.surfaces)
        field = "bSplineCoefficients" + foot;
        valuesStruct.(field) = inputs.surfaces{foot}.bSplineCoefficients;
    end
end
if ~params.tasks{task}.designVariables(7)
    for foot = 1:length(inputs.surfaces)
        field = "electricalCenterX" + foot;
        valuesStruct.(field) = ...
            inputs.surfaces{foot}.electricalCenterShiftX;
    end
end
if ~params.tasks{task}.designVariables(8)
    for foot = 1:length(inputs.surfaces)
        field = "electricalCenterY" + foot;
        valuesStruct.(field) = ...
            inputs.surfaces{foot}.electricalCenterShiftY;
    end
end
if ~params.tasks{task}.designVariables(9)
    for foot = 1:length(inputs.surfaces)
        field = "electricalCenterZ" + foot;
        valuesStruct.(field) = ...
            inputs.surfaces{foot}.electricalCenterShiftZ;
    end
end
if ~params.tasks{task}.designVariables(10)
    for foot = 1:length(inputs.surfaces)
        field = "forcePlateRotation" + foot;
        valuesStruct.(field) = ...
            inputs.surfaces{foot}.forcePlateRotation;
    end
end

for foot = 1 : length(inputs.surfaces)
    for i = 1 : size(inputs.surfaces{foot} ...
            .experimentalGroundReactionMoments, 2)
        inputs.surfaces{foot}.experimentalGroundReactionMoments(:, i) = ...
            inputs.surfaces{foot} ...
            .experimentalGroundReactionMoments(:, i) + ...
            cross([0; -valuesStruct.restingSpringLength; 0], ...
            inputs.surfaces{foot}.experimentalGroundReactionForces(:, i));
    end
end

% Electrical center shift
if any(params.tasks{task}.designVariables(7:9))
    for foot = 1:length(inputs.surfaces)
        fieldX = "electricalCenterX" + foot;
        fieldY = "electricalCenterY" + foot;
        fieldZ = "electricalCenterZ" + foot;
        electricalCenterShift = [valuesStruct.(fieldX); ...
            valuesStruct.(fieldY); valuesStruct.(fieldZ)];

        for i = 1 : size( ...
                inputs.surfaces{foot}.experimentalGroundReactionMoments, 2)
            inputs.surfaces{foot} ...
                .experimentalGroundReactionMoments(:, i) = ...
                inputs.surfaces{foot} ...
                .experimentalGroundReactionMoments(:, i) + ...
                cross(electricalCenterShift, inputs.surfaces{foot} ...
                .experimentalGroundReactionForces(:, i));
        end
    end
end

% Force plate rotation
if params.tasks{task}.designVariables(10)
    for foot = 1:length(inputs.surfaces)
        [inputs.surfaces{foot}.experimentalGroundReactionForces, ...
            inputs.surfaces{foot}.experimentalGroundReactionMoments] = ...
            rotateGroundReactions( ...
            inputs.surfaces{foot}.experimentalGroundReactionForces, ...
            inputs.surfaces{foot}.experimentalGroundReactionMoments, ...
            inputs.surfaces{foot}.forcePlateRotation);
    end
end

cost = [];
for foot = 1:length(inputs.surfaces)
    field = "bSplineCoefficients" + foot;
    valuesBSplineCoefficients = ...
        reshape(valuesStruct.(field), [], 7);
    [modeledJointPositions, modeledJointVelocities] = ...
        calcGCPJointKinematics(inputs.surfaces{foot} ...
        .experimentalJointPositions, inputs.surfaces{foot} ...
        .jointKinematicsBSplines, valuesBSplineCoefficients);
    modeledValues = calcGCPModeledValues(inputs, valuesStruct, ...
        modeledJointPositions, modeledJointVelocities, params, task, ...
        foot, models);
    modeledValues.jointPositions = modeledJointPositions;
    modeledValues.jointVelocities = modeledJointVelocities;

    cost = [cost calcCost(inputs, params, modeledValues, valuesStruct, ...
        task, foot)];
end
end

% Reformats the values array of design variables to a simpler struct. 
function valuesStruct = unpackValues(values, inputs, fieldNameOrder)
valuesStruct = struct();
start = 1;
for i=1:length(fieldNameOrder)
    % Kinematics are specific to each foot, but other design variables are
    % shared. 
    if contains(fieldNameOrder(i), "bSplineCoefficients")
        foot = convertStringsToChars(fieldNameOrder(i));
        foot = str2double(foot(end));
        valuesStruct.(fieldNameOrder(i)) = values(start:start + ...
            numel(inputs.surfaces{foot}.bSplineCoefficients) - 1);
        start = start + numel(inputs.surfaces{foot}.bSplineCoefficients);
    elseif contains(fieldNameOrder(i), "electricalCenterX")
        valuesStruct.(fieldNameOrder(i)) = values(start);
        start = start + 1;
    elseif contains(fieldNameOrder(i), "electricalCenterY")
        valuesStruct.(fieldNameOrder(i)) = values(start);
        start = start + 1;
    elseif contains(fieldNameOrder(i), "electricalCenterZ")
        valuesStruct.(fieldNameOrder(i)) = values(start);
        start = start + 1;
    elseif contains(fieldNameOrder(i), "forcePlateRotation")
        valuesStruct.(fieldNameOrder(i)) = values(start);
        start = start + 1;
    else
        valuesStruct.(fieldNameOrder(i)) = values(start:start + ...
            numel(inputs.(fieldNameOrder(i))) - 1);
        if fieldNameOrder(i) == "springConstants"
            valuesStruct.(fieldNameOrder(i)) = ...
                1000 * valuesStruct.(fieldNameOrder(i));
        end
        start = start + numel(inputs.(fieldNameOrder(i)));
    end
end
end

% Calculates the overall cost using allowable errors and all included cost
% terms. 
function cost = calcCost(inputs, params, modeledValues, valuesStruct, ...
    task, foot)
cost = [];
% Prepare reused cost calculations
includedCostTypes = [];
for term = 1:length(params.tasks{task}.costTerms)
    if params.tasks{task}.costTerms{term}.isEnabled
        includedCostTypes = [includedCostTypes convertCharsToStrings( ...
            params.tasks{task}.costTerms{term}.type)];
    end
end
if ~isempty(intersect(includedCostTypes, ...
        ["marker_position" "marker_slope"]))
    [footMarkerPositionError, footMarkerSlopeError] = ...
        calcFootMarkerPositionAndSlopeError(inputs.surfaces{foot}, ...
        modeledValues);
end
if ~isempty(intersect(includedCostTypes, ["vertical_grf" ...
        "vertical_grf_slope" "horizontal_grf" "horizontal_grf_slope"]))
    if ~isfield(modeledValues, 'anteriorGrf')
        modeledValues.anteriorGrf = zeros(size(modeledValues.verticalGrf));
        modeledValues.lateralGrf = zeros(size(modeledValues.verticalGrf));
    end
    [groundReactionForceValueErrors, groundReactionForceSlopeErrors] = ...
        calcGroundReactionForceAndSlopeError(inputs.surfaces{foot}, ...
        modeledValues);
end
if ~isempty(intersect(includedCostTypes, ...
        ["ground_reaction_moment" "ground_reaction_moment_slope"]))
    [groundReactionMomentErrors, groundReactionMomentSlopeErrors] = ...
        calcGroundReactionMomentAndSlopeError(inputs.surfaces{foot}, ...
        modeledValues); 
end
% Append all cost terms
for term = 1:length(params.tasks{task}.costTerms)
    costTerm = params.tasks{task}.costTerms{term};
    if costTerm.isEnabled
        switch costTerm.type
            case "marker_position"
                rawCost = footMarkerPositionError;
            case "marker_slope"
                rawCost = footMarkerSlopeError;
            case "rotation"
                rawCost = reshape(modeledValues ...
                    .jointPositions(1:4, :) - inputs ...
                    .surfaces{foot}.experimentalJointPositions(1:4, ...
                    :), 1, []);
            case "translation"
                rawCost = reshape(modeledValues.jointPositions(5:7, :) ...
                    - inputs.surfaces{foot}.experimentalJointPositions( ...
                    5:7, :), 1, []);
            case "kinematic_periodicity"
                rawCost = calcFootPositionPeriodicityError( ...
                    modeledValues.jointPositions, ...
                    inputs.surfaces{foot}.experimentalJointPositions);
            case "vertical_grf"
                rawCost = groundReactionForceValueErrors(2, :);
            case "vertical_grf_slope"
                rawCost = groundReactionForceSlopeErrors(2, :);
            case "horizontal_grf"
                rawCost = reshape(groundReactionForceValueErrors([1 3], ...
                    :), 1, []);
            case "horizontal_grf_slope"
                rawCost = reshape(groundReactionForceSlopeErrors([1 3], ...
                    :), 1, []);
            case "ground_reaction_moment"
                rawCost = reshape(groundReactionMomentErrors, 1, []);
            case "ground_reaction_moment_slope"
                rawCost = reshape(groundReactionMomentSlopeErrors, 1, []);
            case "spring_constant_mean"
                rawCost = calcSpringConstantsErrorFromMean( ...
                    valuesStruct.springConstants);
            case "neighbor_spring_constant"
                rawCost = (calcSpringConstantsErrorFromNeighbors( ...
                    valuesStruct.springConstants, ...
                    modeledValues.gaussianWeights) / ...
                    costTerm.maxAllowableError) .^ 4 * ...
                    costTerm.maxAllowableError;
            case "electrical_center_regularization"
                rawCost = calcElectricalCenterShiftError(inputs, ...
                    valuesStruct, costTerm);
            case "force_plate_rotation_regularization"
                rawCost = calcForcePlateRotationError(inputs, ...
                    valuesStruct);
            otherwise
                throw(MException('', ['Cost term type ' costTerm.type ...
                    ' does not exist for this tool.']))
        end
        cost = [cost sqrt(1 / length(rawCost)) * ...
            1 / costTerm.maxAllowableError * rawCost];
    end
end
end
