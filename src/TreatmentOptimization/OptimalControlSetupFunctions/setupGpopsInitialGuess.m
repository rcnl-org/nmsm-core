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
        inputs.statesCoordinateNames);
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
    guess.phase.state = scaleToBounds([ ...
        stateJointAngles, ...
        stateJointVelocities, ...
        ], inputs.maxState, ...
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
if isfield(inputs, "initialAccelerations")
    controls = inputs.initialAccelerations;
else
    stateJointAccelerations = subsetDataByCoordinates( ...
        inputs.initialJointAccelerations, ...
        inputs.initialCoordinateNames, ...
        inputs.statesCoordinateNames);

    controls = stateJointAccelerations;
end
if inputs.controllerTypes(3)
    if isfield(inputs, "initialMuscleControls")
        controls = [controls, inputs.initialMuscleControls];
    else
        throw(MException("NoInitialMuscleControls", ...
            strcat("initial muscle controls required for muscle", ...
            " controls, have you included initial muscle controls " + ...
            "or an initial value?")));
    end
end
if inputs.controllerTypes(2)
    if isfield(inputs, "initialSynergyControls")
        controls = [controls, inputs.initialSynergyControls];
    else
        throw(MException("NoInitialSynergyControls", ...
            strcat("initial synergy controls required for synergy", ...
            " driven, have you run NCP?")));
    end
end
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
    coordinateNames, subsetOfCoordinateNames)
includedSubset = ismember(coordinateNames, subsetOfCoordinateNames);
numCoordinates = length(includedSubset) / 2;
for i = 1:numCoordinates
    if includedSubset(i)
        includedSubset(i + numCoordinates) = true;
    end
end
output = data(:, includedSubset);
end