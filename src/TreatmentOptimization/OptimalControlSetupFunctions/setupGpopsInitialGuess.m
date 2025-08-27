% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets up the common initial guess for an optimal control
% problem and is used by Tracking Optimization, Verification Optimization,
% and Design Optimization
%
% (struct) -> (struct)
% return a set of setup values common to all optimal control problems

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

function [inputs, guess] = setupGpopsInitialGuess(inputs)
guess = struct();
guess = setupInitialStatesGuess(inputs, guess);
guess = setupInitialControlsGuess(inputs, guess);
[inputs, guess] = setupInitialParametersGuess(inputs, guess);
% guess.phase.integral = scaleToBounds(1, inputs.continuousMaxAllowableError, ...
%     zeros(size(inputs.continuousMaxAllowableError)));
guess.phase.integral = zeros(size(inputs.continuousMaxAllowableError));
% guess.phase.integral = trapz(inputs.initialCost);
if valueOrAlternate(inputs, 'calculateMetabolicCost', false)
    guess.phase.integral(:, end + 1) = 1;
end
end

function guess = setupInitialStatesGuess(inputs, guess)
if isfield(inputs, "initialStates")
    states = subsetInitialStatesDataByCoordinates( ...
        inputs.initialStates, ...
        inputs.initialStatesLabels, ...
        inputs.statesCoordinateNames, inputs.useJerk);
    if inputs.useControlDerivatives
        if inputs.controllerTypes(4)
            states = [states, inputs.initialUserDefinedControls];
        end
        if inputs.controllerTypes(3)
            states = [states, inputs.initialMuscleControls];
        end
        if inputs.controllerTypes(2)
            states = [states, inputs.initialSynergyControls];
        end
        if inputs.controllerTypes(1)
            states = [states, inputs.initialTorqueControls];
        end
    end
    guess.phase.state = scaleToBounds(states, ...
        inputs.maxState, inputs.minState);
    if strcmp(inputs.solverType, 'casadi')
        guess.phase.time = scaleToBounds( ...
            inputs.collocationTimeOriginalWithEnd, inputs.maxTime, ...
            inputs.minTime);
    else
        guess.phase.time = scaleToBounds(inputs.initialTime, ...
            inputs.maxTime, inputs.minTime);
    end
else
    stateJointAngles = subsetDataByCoordinates( ...
        inputs.initialJointAngles, ...
        inputs.initialCoordinateNames, ...
        inputs.statesCoordinateNames);
    stateJointVelocities = subsetDataByCoordinates( ...
        inputs.initialJointVelocities, ...
        inputs.initialCoordinateNames, ...
        inputs.statesCoordinateNames);
    stateGuess = [stateJointAngles, stateJointVelocities];
    if inputs.useJerk
        stateJointAccelerations = subsetDataByCoordinates( ...
            inputs.initialJointAccelerations, ...
            inputs.initialCoordinateNames, ...
            inputs.statesCoordinateNames);
        stateGuess = [stateGuess, stateJointAccelerations];
    end
    if inputs.useControlDerivatives
        if inputs.controllerTypes(4)
            stateGuess = [stateGuess, inputs.initialUserDefinedControls];
        end
        if inputs.controllerTypes(3)
            stateGuess = [stateGuess, inputs.initialMuscleControls];
        end
        if inputs.controllerTypes(2)
            stateGuess = [stateGuess, inputs.initialSynergyControls];
        end
        if inputs.controllerTypes(1)
            stateGuess = [stateGuess, inputs.initialTorqueControls];
        end
    end

    guess.phase.state = scaleToBounds(stateGuess, inputs.maxState, ...
        inputs.minState);
    if strcmp(inputs.solverType, 'casadi')
        guess.phase.time = scaleToBounds( ...
            inputs.collocationTimeOriginalWithEnd, inputs.maxTime, ...
            inputs.minTime);
    else
        guess.phase.time = scaleToBounds(inputs.initialTime, ...
            inputs.maxTime, inputs.minTime);
    end
end
end

function guess = setupInitialControlsGuess(inputs, guess)
if inputs.useJerk
    if isfield(inputs, "initialJerks")
        controls = inputs.initialJerks;
    else
        stateJointJerks = subsetDataByCoordinates( ...
            inputs.initialJointJerks, ...
            inputs.initialCoordinateNames, ...
            inputs.statesCoordinateNames);

        controls = stateJointJerks;
    end
else
    if isfield(inputs, "initialAccelerations")
        controls = inputs.initialAccelerations;
    else
        stateJointAccelerations = subsetDataByCoordinates( ...
            inputs.initialJointAccelerations, ...
            inputs.initialCoordinateNames, ...
            inputs.statesCoordinateNames);

        controls = stateJointAccelerations;
    end
end
if inputs.controllerTypes(4)
    if inputs.useControlDerivatives
        controls = [controls, inputs.initialUserDefinedControlDerivatives];
    else
        if isfield(inputs, "initialUserDefinedControls")
            controls = [controls, inputs.initialUserDefinedControls];
        else
            throw(MException("NoInitialUserDefinedControls", ...
                strcat("initial user-defined controls required ", ...
                ", have you included initial user-defined controls " + ...
                "or an initial value?")));
        end
    end
end
if inputs.controllerTypes(3)
    if inputs.useControlDerivatives
        controls = [controls, inputs.initialMuscleControlDerivatives];
    else
        if isfield(inputs, "initialMuscleControls")
            controls = [controls, inputs.initialMuscleControls];
        else
            throw(MException("NoInitialMuscleControls", ...
                strcat("initial muscle controls required for muscle", ...
                " controls, have you included initial muscle controls " + ...
                "or an initial value?")));
        end
    end
end
if inputs.controllerTypes(2)
    if inputs.useControlDerivatives
        controls = [controls, inputs.initialSynergyControlDerivatives];
    else
        if isfield(inputs, "initialSynergyControls")
            controls = [controls, inputs.initialSynergyControls];
        else
            throw(MException("NoInitialSynergyControls", ...
                strcat("initial synergy controls required for synergy", ...
                " driven, have you run NCP?")));
        end
    end
end
if inputs.useControlDerivatives && inputs.controllerTypes(1)
    controls = [controls, inputs.initialTorqueControlDerivatives];
else
    if isfield(inputs, "initialTorqueControls")
        controls = [controls, inputs.initialTorqueControls];
    else
        if ~isempty(valueOrAlternate(inputs, "torqueControllerCoordinateNames", []))
            stateTorqueControls = subsetDataByCoordinates( ...
                inputs.initialJointMoments, ...
                erase(erase(inputs.initialInverseDynamicsMomentLabels, '_moment'), '_force'), ...
                inputs.torqueControllerCoordinateNames);
            if size(controls, 1) ~= size(stateTorqueControls, 1)
                torqueSplines = makeGcvSplineSet(inputs.initialTime, ...
                    stateTorqueControls, ...
                    inputs.torqueControllerCoordinateNames);
                if strcmp(inputs.solverType, 'gpops')
                    stateTorqueControls = evaluateGcvSplines(torqueSplines, ...
                        inputs.torqueControllerCoordinateNames, ...
                        inputs.collocationTimeOriginal);
                else
                    stateTorqueControls = evaluateGcvSplines(torqueSplines, ...
                        inputs.torqueControllerCoordinateNames, ...
                        inputs.collocationTimeOriginalWithEnd);
                end
            end
            controls = [controls, stateTorqueControls];
        end
    end
end
guess.phase.control = scaleToBounds(controls, inputs.maxControl, ...
    inputs.minControl);
end

function [inputs, guess] = setupInitialParametersGuess(inputs, guess)
if valueOrAlternate(inputs, "optimizeSynergyVectors", false)
    guess.parameter = [];
    inputs.synergyWeightsIndices = [];
    row = 1;
    for i = 1 : length(inputs.synergyGroups)
        for k = 1:inputs.synergyGroups{i}.numSynergies
            for j = 1 : length(inputs.synergyGroups{i}.muscleNames)
                index = find(ismember(inputs.synergyWeightsLabels, ...
                    inputs.synergyGroups{i}.muscleNames{j}));
                inputs.synergyWeightsIndices(end + 1) = ...
                    size(inputs.synergyWeights, 1) * ...
                    (index - 1) + row + k - 1;
                guess.parameter(end + 1) = inputs.synergyWeights( ...
                    inputs.synergyWeightsIndices(end));
            end
        end
        row = row + inputs.synergyGroups{i}.numSynergies;
    end
end
for i = 1:length(inputs.userDefinedVariables)
    if ~isfield(guess, "parameter")
        guess.parameter = [];
    end
    guess.parameter = [guess.parameter, ...
        inputs.userDefinedVariables{i}.initial_values];
end
if isfield(guess, "parameter")
    guess.parameter = scaleToBounds(guess.parameter, inputs.maxParameter, ...
        inputs.minParameter);
    guess.phase.parameter = guess.parameter;
end
end

function output = subsetInitialStatesDataByCoordinates(data, ...
    coordinateNames, subsetOfCoordinateNames, useJerk)
includedSubset = ismember(coordinateNames, subsetOfCoordinateNames);
if useJerk
    numCoordinates = length(includedSubset) / 3;
else
    numCoordinates = length(includedSubset) / 2;
end
for i = 1:numCoordinates
    if includedSubset(i)
        includedSubset(i + numCoordinates) = true;
        if useJerk
            includedSubset(i + 2 * numCoordinates) = true;
        end
    end
end
output = data(:, includedSubset);
end