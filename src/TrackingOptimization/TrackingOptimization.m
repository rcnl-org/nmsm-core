% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function [output, inputs] = TrackingOptimization(inputs, params)
pointKinematics(inputs.mexModel);
inverseDynamics(inputs.mexModel);
inputs = getIntegralBounds(inputs);
inputs = getPathConstraintBounds(inputs);
inputs = getTerminalConstraintBounds(inputs); 
inputs = getDesignVariableInputBounds(inputs);
output = computeTrackingOptimizationMainFunction(inputs, params);
end
function inputs = getDesignVariableInputBounds(inputs)
inputs.maxTime = max(inputs.experimentalTime);
inputs.minTime = min(inputs.experimentalTime);

maxStatePositions = max(inputs.experimentalJointAngles) + ...
    inputs.statePositionsMultiple * range(inputs.experimentalJointAngles);
minStatePositions = min(inputs.experimentalJointAngles) - ...
    inputs.statePositionsMultiple * range(inputs.experimentalJointAngles);
maxStateVelocities = max(inputs.experimentalJointVelocities) + ...
    inputs.stateVelocitiesMultiple * range(inputs.experimentalJointVelocities);
minStateVelocities = min(inputs.experimentalJointVelocities) - ...
    inputs.stateVelocitiesMultiple * range(inputs.experimentalJointVelocities);
maxStateAccelerations = max(inputs.experimentalJointAccelerations) + ...
    inputs.stateAccelerationsMultiple * range(inputs.experimentalJointAccelerations);
minStateAccelerations = min(inputs.experimentalJointAccelerations) - ...
    inputs.stateAccelerationsMultiple * range(inputs.experimentalJointAccelerations);

inputs.maxState = [maxStatePositions maxStateVelocities maxStateAccelerations];
inputs.minState = [minStatePositions minStateVelocities minStateAccelerations];

maxControlJerks = max(inputs.experimentalJointJerks) + ...
    inputs.controlJerksMultiple * range(inputs.experimentalJointJerks);
minControlJerks = min(inputs.experimentalJointJerks) - ...
    inputs.controlJerksMultiple * range(inputs.experimentalJointJerks);

if strcmp(inputs.controllerType, 'synergy_driven') 
maxControlNeuralCommands = inputs.maxControlNeuralCommands * ...
    ones(1, inputs.numSynergies);
inputs.maxControl = [maxControlJerks maxControlNeuralCommands];
inputs.minControl = [minControlJerks zeros(1, inputs.numSynergies)];

inputs.maxParameter = inputs.maxParameterSynergyWeights * ...
    ones(1, inputs.numSynergyWeights);
inputs.minParameter = zeros(1, inputs.numSynergyWeights);
elseif strcmp(inputs.controllerType, 'torque_driven') 
maxControlTorques = max(inputs.experimentalJointMoments(:, ...
    inputs.torqueActuatedMomentsIndex)) + inputs.maxControlTorquesMultiple * ...
    range(inputs.experimentalJointMoments(:, inputs.torqueActuatedMomentsIndex));
minControlTorques = min(inputs.experimentalJointMoments(:, ...
    inputs.torqueActuatedMomentsIndex)) - inputs.maxControlTorquesMultiple * ...
    range(inputs.experimentalJointMoments(:, inputs.torqueActuatedMomentsIndex));
inputs.maxControl = [maxControlJerks maxControlTorques];
inputs.minControl = [minControlJerks minControlTorques];
end
end
function inputs = getIntegralBounds(inputs)
inputs.integralOptions = {};
inputs.maxIntegral = [];
inputs.isEnabled = zeros(1, 6);

trackCoordinates = valueOrAlternate(inputs, "trackedCoordinateEnabled", 0);
if trackCoordinates
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedCoordinateIndex] = getIntegralSettings( ...
        inputs.trackedCoordinate, inputs.coordinateNames, inputs.maxIntegral);
    inputs.isEnabled(1) = 1;
end
trackLoads = valueOrAlternate(inputs, "trackedLoadEnabled", 0);
if trackLoads
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedInverseDynamicMomentsIndex] = getIntegralSettings( ...
        inputs.trackedLoad, inputs.inverseDynamicMomentLabels, ...
        inputs.maxIntegral);
    inputs.isEnabled(2) = 1;
end
trackExternalForces = valueOrAlternate(inputs, "trackedExternalForceEnabled", 0);
if trackExternalForces
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedExternalForcesIndex] = getIntegralSettings( ...
        inputs.trackedExternalForce, [inputs.rightGroundReactionLabels, ...
        inputs.leftGroundReactionLabels], inputs.maxIntegral);
    inputs.isEnabled(3) = 1;
end
trackExternalMoments = valueOrAlternate(inputs, "trackedExternalMomentEnabled", 0);
if trackExternalMoments
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedExternalMomentsIndex] = getIntegralSettings( ...
        inputs.trackedExternalMoment, [inputs.rightGroundReactionLabels, ...
        inputs.leftGroundReactionLabels], inputs.maxIntegral);
    inputs.isEnabled(4) = 1;
end
trackMuscleActivation = valueOrAlternate(inputs, "trackedMuscleActivationEnabled", 0);
if trackMuscleActivation
    inputs.integralOptions{end+1} = ...
        inputs.trackedMuscleActivationMaxAllowableError * ...
        ones(1, inputs.numMuscles);
    inputs.maxIntegral = cat(2, inputs.maxIntegral, ...
        nonzeros(inputs.integralOptions{end})');
    inputs.isEnabled(5) = 1;
end
minimizeJointJerk = valueOrAlternate(inputs, "minimizedCoordinateEnabled", 0);
if minimizeJointJerk
    inputs.integralOptions{end+1} = ...
        inputs.minimizedCoordinateMaxAllowableError * ...
        range(inputs.experimentalJointJerks);
    inputs.maxIntegral = cat(2, inputs.maxIntegral, ...
        nonzeros(inputs.integralOptions{end})');
    inputs.isEnabled(6) = 1;
 end
inputs.minIntegral = zeros(1, length(inputs.maxIntegral));
end
function [integralOptions, maxIntegral, trackedQuantityIndex] = ...
    getIntegralSettings(trackedQuantity, modelComponentNames, tempMaxIntegral)
integralOptions = getMaximumAllowableErrors( ...
    trackedQuantity, modelComponentNames);
maxIntegral = cat(2, tempMaxIntegral, nonzeros(integralOptions)');
trackedQuantityIndex = find(integralOptions);
integralOptions(integralOptions == 0) = [];
end
function output = getMaximumAllowableErrors(trackedQuantity, ...
    modelComponentNames)
output = zeros(1, length(modelComponentNames));
for i = 1 : length(modelComponentNames)
    for j = 1 : length(trackedQuantity.names)
        if strcmpi(modelComponentNames{i}, trackedQuantity.names{j})
            output(i) = trackedQuantity.maxAllowableErrors(j);
        end
    end
end
end
function output = getMinimumAllowableErrors(trackedQuantity, ...
    modelComponentNames)
output = zeros(1, length(modelComponentNames));
for i = 1 : length(modelComponentNames)
    for j = 1 : length(trackedQuantity.names)
        if strcmpi(modelComponentNames{i}, trackedQuantity.names{j})
            output(i) = trackedQuantity.minAllowableErrors(j);
        end
    end
end
end
function inputs = getPathConstraintBounds(inputs)
inputs.maxPath = [];
inputs.minPath = [];
rootSegmentResidualsPathConstraint = valueOrAlternate(inputs, ...
    "rootSegmentResidualLoadPathConstraint", 0);
if rootSegmentResidualsPathConstraint
    maxAllowablePathError = getMaximumAllowableErrors( ...
        inputs.rootSegmentResidualLoad, inputs.inverseDynamicMomentLabels);
    inputs.maxPath = nonzeros(maxAllowablePathError)';
    inputs.rootSegmentResidualsIndex = find(maxAllowablePathError);
    minAllowablePathError = getMinimumAllowableErrors( ...
        inputs.rootSegmentResidualLoad, inputs.inverseDynamicMomentLabels);
    inputs.minPath = nonzeros(minAllowablePathError)';
end
muscleModelLoadPathConstraint = valueOrAlternate(inputs, ...
    "muscleModelLoadPathConstraint", 0);
if muscleModelLoadPathConstraint
    maxAllowablePathError = getMaximumAllowableErrors( ...
        inputs.muscleModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.maxPath = cat(2, inputs.maxPath, ...
        nonzeros(maxAllowablePathError)');
    inputs.muscleActuatedMomentsIndex = find(maxAllowablePathError);
    minAllowablePathError = getMinimumAllowableErrors( ...
        inputs.muscleModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.minPath = cat(2, inputs.minPath, ...
        nonzeros(minAllowablePathError)');
    for i = 1 : length(inputs.dofsActuatedLabels)
        for j = 1 : length(inputs.inverseDynamicMomentLabels)
            if strcmpi(inputs.dofsActuatedLabels{i}, inputs.inverseDynamicMomentLabels(j))
                inputs.dofsActuatedIndex(i) = j;
            end
        end 
    end
end
controllerModelLoadPathConstraint = valueOrAlternate(inputs, ...
    "controllerModelLoadPathConstraint", 0);
if controllerModelLoadPathConstraint
    maxAllowablePathError = getMaximumAllowableErrors( ...
        inputs.controllerModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.maxPath = cat(2, inputs.maxPath, ...
        nonzeros(maxAllowablePathError)');
    inputs.torqueActuatedMomentsIndex = find(maxAllowablePathError);
    minAllowablePathError = getMinimumAllowableErrors( ...
        inputs.controllerModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.minPath = cat(2, inputs.minPath, ...
        nonzeros(minAllowablePathError)');
end
end
function inputs = getTerminalConstraintBounds(inputs)
inputs.maxTerminal = [];
inputs.minTerminal = [];
statePositionPeriodicityConstraint = valueOrAlternate(inputs, ...
    "statePositionPeriodicityConstraint", 0);
if statePositionPeriodicityConstraint
    inputs.maxTerminal = inputs.statePositionPeriodicityMaxAllowableError * ...
        ones(1, inputs.numCoordinates);
    inputs.minTerminal = inputs.statePositionPeriodicityMinAllowableError * ...
        ones(1, inputs.numCoordinates);
end
stateVelocityPeriodicityConstraint = valueOrAlternate(inputs, ...
    "stateVelocityPeriodicityConstraint", 0);
if stateVelocityPeriodicityConstraint
    inputs.maxTerminal = cat(2, inputs.maxTerminal, ...
        inputs.stateVelocityPeriodicityMaxAllowableError * ...
        ones(1, inputs.numCoordinates));
    inputs.minTerminal = cat(2, inputs.minTerminal, ...
        inputs.stateVelocityPeriodicityMinAllowableError * ...
        ones(1, inputs.numCoordinates));
end
rootSegmentResidualLoadPeriodicityConstraint = valueOrAlternate(inputs, ...
    "rootSegmentResidualLoadPeriodicityConstraint", 0);
if rootSegmentResidualLoadPeriodicityConstraint
    inputs.maxTerminal = cat(2, inputs.maxTerminal, ...
        inputs.rootSegmentResidualLoadPeriodicityMaxAllowableError * ...
        ones(1, length(inputs.rootSegmentResidualsIndex)));
    inputs.minTerminal = cat(2, inputs.minTerminal, ...
        inputs.rootSegmentResidualLoadPeriodicityMinAllowableError * ...
        ones(1, length(inputs.rootSegmentResidualsIndex)));
end
externalForcePeriodicityConstraint = valueOrAlternate(inputs, ...
    "externalForcePeriodicityConstraint", 0);
if externalForcePeriodicityConstraint
    inputs.maxTerminal = cat(2, inputs.maxTerminal, ...
        inputs.externalForcePeriodicityMaxAllowableError * ...
        ones(1, length(inputs.trackedExternalForcesIndex)));
    inputs.minTerminal = cat(2, inputs.minTerminal, ...
        inputs.externalForcePeriodicityMinAllowableError * ...
        ones(1, length(inputs.trackedExternalForcesIndex)));
end
externalMomentPeriodicityConstraint = valueOrAlternate(inputs, ...
    "externalMomentPeriodicityConstraint", 0);
if externalMomentPeriodicityConstraint
    inputs.maxTerminal = cat(2, inputs.maxTerminal, ...
        inputs.externalMomentPeriodicityMaxAllowableError * ...
        ones(1, length(inputs.trackedExternalMomentsIndex)));
    inputs.minTerminal = cat(2, inputs.minTerminal, ...
        inputs.externalMomentPeriodicityMinAllowableError * ...
        ones(1, length(inputs.trackedExternalMomentsIndex)));
end
synergyWeightsSumConstraint = valueOrAlternate(inputs, ...
    "synergyWeightsSumConstraint", 0);
if synergyWeightsSumConstraint
    inputs.maxTerminal = cat(2, inputs.maxTerminal, ...
        inputs.synergyWeightsSumMaxAllowableError * ...
        ones(1, inputs.numSynergies));
    inputs.minTerminal = cat(2, inputs.minTerminal, ...
        inputs.synergyWeightsSumMinAllowableError * ...
        ones(1, inputs.numSynergies));
end
end