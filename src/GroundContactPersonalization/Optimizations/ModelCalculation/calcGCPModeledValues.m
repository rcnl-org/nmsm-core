% This function is part of the NMSM Pipeline, see file for full license.
%
% This function steps through each modeledJointKinematics position and
% calculates the necessary values based on the true values in the
% isCalculated boolean array, determined using included costs in the
% current stage. 
%
% isCalculated indices (in order);
%   - Marker positions and velocities
%   - Vertical ground reaction force
%   - Horizontal ground reaction force
%   - Ground reaction moments
%
% (struct, struct, Array of double, Array of double, struct, struct, 
% double, struct) -> (struct)
% Calculate modeled values for the GCP cost function.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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

function modeledValues = calcGCPModeledValues(inputs, values, ...
    modeledJointPositions, modeledJointVelocities, params, task, foot, ...
    models)
model = models.("model_" + foot);
if ~isequal(mexext, 'mexw64')
    state = model.initSystem();
end
markerNamesFields = fieldnames(inputs.surfaces{foot}.markerNames);
% If a design variable is not included, its static value from the inputs
% struct is temporarily placed in values so it can be used to calculate
% modeled values.
if ~params.tasks{task}.designVariables(1)
    values.springConstants = inputs.springConstants;
end
if ~params.tasks{task}.designVariables(2)
    values.dampingFactor = inputs.dampingFactor;
end
if ~params.tasks{task}.designVariables(3)
    values.dynamicFrictionCoefficient = inputs.dynamicFrictionCoefficient;
end
if ~params.tasks{task}.designVariables(4)
    values.viscousFrictionCoefficient = inputs.viscousFrictionCoefficient;
end
if ~params.tasks{task}.designVariables(5)
    values.restingSpringLength = inputs.restingSpringLength;
end
for i=1:length(markerNamesFields)
    modeledValues.markerPositions.(markerNamesFields{i}) = ...
        zeros(3, size(modeledJointPositions, 2));
    modeledValues.markerVelocities.(markerNamesFields{i}) = ...
        zeros(3, size(modeledJointPositions, 2));
end
modeledValues.verticalGrf = zeros(1, size(modeledJointPositions, 2));

% Determine which modeled values to calculate based on included cost terms.
includedCostTypes = [];
for term = 1:length(params.tasks{task}.costTerms)
    if params.tasks{task}.costTerms{term}.isEnabled
        includedCostTypes = [includedCostTypes convertCharsToStrings( ...
            params.tasks{task}.costTerms{term}.type)];
    end
end
isCalculated = ones(4, 1);
if isempty(intersect(includedCostTypes, ["ground_reaction_moment", ...
        "ground_reaction_moment_slope"]))
    isCalculated(4) = false;
    if isempty(intersect(includedCostTypes, ["horizontal_grf", ...
            "horizontal_grf_slope"]))
        isCalculated(3) = false;
    end
end
if ~isempty(intersect(includedCostTypes, "neighbor_spring_constant"))
    modeledValues.gaussianWeights = zeros(size( ...
        modeledJointPositions, 2), length(inputs.springConstants), ...
        length(inputs.springConstants));
end
% Calculate modeled values
if isCalculated(1) && isequal(mexext, 'mexw64')
    [modeledValues.markerPositions, modeledValues.markerVelocities] = ...
        findModeledMarkerCoordinatesMex(inputs.surfaces{foot}, ...
        modeledJointPositions, modeledJointVelocities, ...
        inputs.osimVersion, foot);
end
if isCalculated(2) && isequal(mexext, 'mexw64')
    [springPositions, springVelocities] = ...
        findModeledSpringMarkerCoordinatesMex(inputs.surfaces{foot}, ...
        modeledJointPositions, modeledJointVelocities, ...
        inputs.osimVersion, foot);
end
for i=1:size(modeledJointPositions, 2)
    if ~isequal(mexext, 'mexw64')
        [model, state] = updateModelPositionAndVelocity(model, state, ...
            modeledJointPositions(:, i), ...
            modeledJointVelocities(:, i), inputs.surfaces{foot});
    end
    % Foot marker positions and velocities
    if isCalculated(1) && ~isequal(mexext, 'mexw64')
        [modeledValues.markerPositions, ...
            modeledValues.markerVelocities] ...
            = findModeledMarkerCoordinates(model, state, ...
            modeledValues.markerPositions, ...
            inputs.surfaces{foot}.markerNames, i);
    end
    % Vertical ground reaction force
    if isCalculated(2)
        markerKinematics.height = zeros(size(values.springConstants));
        markerKinematics.yVelocity = zeros(size(values.springConstants));
        springForces = zeros(3, length(values.springConstants));
        % Get position and velocity for each spring marker
        for j = 1:length(values.springConstants)
            if isequal(mexext, 'mexw64')
                markerKinematics.height(j) = springPositions(i, 2, j);
                markerKinematics.yVelocity(j) = springVelocities(i, 2, j);
            else
                modelMarkerPosition = model.getMarkerSet().get(...
                    "spring_marker_" + num2str(j)).getLocationInGround(state);
                modelMarkerVelocity = model.getMarkerSet().get(...
                    "spring_marker_" + num2str(j)).getVelocityInGround(state);
                modelMarkerPositions(j) = modelMarkerPosition;
                modelMarkerVelocities(j) = modelMarkerVelocity;
                markerKinematics.height(j) = modelMarkerPositions(j).get(1);
                markerKinematics.yVelocity(j) = modelMarkerVelocities(j) ...
                    .get(1);
            end
        end
        [modeledValues.verticalGrf(i), springForces] = ...
            calcModeledVerticalGroundReactionForce(...
            values.springConstants, values.dampingFactor, ...
            values.restingSpringLength, markerKinematics, springForces);
    end
    % Horizontal ground reaction force
    if isCalculated(3)
        markerKinematics.xVelocity = zeros(size(values.springConstants));
        markerKinematics.zVelocity = zeros(size(values.springConstants));
        for j = 1:length(values.springConstants)
            if isequal(mexext, 'mexw64')
                markerKinematics.xVelocity(j) = springVelocities(i, 1, j);
                markerKinematics.zVelocity(j) = springVelocities(i, 3, j);
            else
                markerKinematics.xVelocity(j) = modelMarkerVelocities(j) ...
                    .get(0);
                markerKinematics.zVelocity(j) = modelMarkerVelocities(j) ...
                    .get(2);
            end
        end
        [modeledValues.anteriorGrf(i), ...
            modeledValues.lateralGrf(i), springForces] = ...
            calcModeledHorizontalGroundReactionForces(values, ...
            inputs.surfaces{foot}.beltSpeed, inputs.latchingVelocity, ...
            markerKinematics, springForces);
    end
    % Ground reaction moments
    if isCalculated(4)
        markerKinematics.xPosition = zeros(size(values.springConstants));
        markerKinematics.zPosition = zeros(size(values.springConstants));

        if isequal(mexext, 'mexw64')
            inputs.surfaces{foot}.midfootSuperiorPosition(:, i) = ...
                modeledValues.markerPositions.midfootSuperior(:, i);
        else
            inputs.surfaces{foot}.midfootSuperiorPosition(:, i) = ...
                model.getMarkerSet().get(...
                inputs.surfaces{foot}.markerNames.midfootSuperior ...
                ).getLocationInGround(state).getAsMat()';
        end

        for j = 1:length(values.springConstants)
            if isequal(mexext, 'mexw64')
                markerKinematics.xPosition(j) = springPositions(i, 1, j);
                markerKinematics.zPosition(j) = springPositions(i, 3, j);
            else
                markerKinematics.xPosition(j) = modelMarkerPositions(j).get(0);
                markerKinematics.zPosition(j) = modelMarkerPositions(j).get(2);
            end
        end
        [modeledValues.xGrfMoment(i), modeledValues.yGrfMoment(i), ...
            modeledValues.zGrfMoment(i)] = ...
            calcModeledGroundReactionMoments(values, ...
            inputs.surfaces{foot}, markerKinematics, springForces, i);
    end
    % Calculate marker- and time-specific Gaussian weights for stiffness
    % deviation from neighbors cost. 
    if ~isempty(intersect(includedCostTypes, "neighbor_spring_constant"))
        for j = 1:length(inputs.springConstants)
            for k = j:length(inputs.springConstants)
                if j ~= k
                    gaussianWeight = calcGaussianWeight( ...
                        markerKinematics.xPosition(j) - ...
                        markerKinematics.xPosition(k), ...
                        markerKinematics.height(j) - ...
                        markerKinematics.height(k), ...
                        markerKinematics.zPosition(j) - ...
                        markerKinematics.zPosition(k), ...
                        params.tasks{task}.neighborStandardDeviation);
                    modeledValues.gaussianWeights(i, j, k) = ...
                        gaussianWeight;
                    modeledValues.gaussianWeights(i, k, j) = ...
                        gaussianWeight;
                end
            end
        end
    end
end
end

% Updates model at each time point
function [model, state] = updateModelPositionAndVelocity(model, state, ...
    jointPositions, jointVelocities, foot)
for j=1:size(jointPositions, 1)
    model.getCoordinateSet().get(j-1).setValue(state, ...
        jointPositions(j));
    model.getCoordinateSet().get(j-1).setSpeedValue(state, ...
        jointVelocities(j));
end
model.assemble(state)
model.realizeVelocity(state)
end

% Calculates a 3D Gaussian weight
function gaussianWeight = calcGaussianWeight(xDistance, yDistance, ...
    zDistance, standardDeviation)
gaussianWeight = exp(-1 / (2 * standardDeviation ^ 2) * ...
    ((xDistance)^2 + (yDistance)^2 + (zDistance)^2));
end

% Use MEX to calculate foot marker kinematics
function [markerPositions, markerVelocities] = ...
        findModeledMarkerCoordinatesMex(surface, ...
        jointAngles, jointVelocities, ...
        version, foot)
funcCall = sprintf(['pointKinematics%i(surface.time'', jointAngles'', ' ...
    'jointVelocities'', surface.footMarkerLocations'', ' ...
    'surface.footMarkerBodies, surface.coordinateLabels)'], foot);
try
    [~, pointPositions, pointVelocities] = evalc(funcCall);
catch
    loadModelCall = sprintf('pointKinematics%i(''footModel_%i.osim'');', ...
        foot, foot);
    evalc(loadModelCall);
    [~, pointPositions, pointVelocities] = evalc(funcCall);
end

markerNamesFields = fieldnames(surface.markerNames);
for i = 1:length(markerNamesFields)
    markerPositions.(markerNamesFields{i}) = ...
        squeeze(pointPositions(:, :, i))';
    markerVelocities.(markerNamesFields{i}) = ...
        squeeze(pointVelocities(:, :, i))';
end
end

% Use MEX to calculate spring marker kinematics
function [markerPositions, markerVelocities] = ...
        findModeledSpringMarkerCoordinatesMex(surface, ...
        jointAngles, jointVelocities, ...
        version, foot)
funcCall = sprintf(['pointKinematics%i(surface.time'', jointAngles'', ' ...
    'jointVelocities'', surface.springMarkerLocations'', ' ...
    'surface.springMarkerBodies, surface.coordinateLabels)'], foot);
[~, markerPositions, markerVelocities] = evalc(funcCall);
end
