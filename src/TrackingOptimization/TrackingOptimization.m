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
inputs = getSplines(inputs);
inputs = getStateDerivatives(inputs);
inputs = checkInitialGuess(inputs);
inputs = getIntegralBounds(inputs);
inputs = getPathConstraintBounds(inputs);
inputs = getTerminalConstraintBounds(inputs); 
inputs = getDesignVariableInputBounds(inputs);
output = computeTrackingOptimizationMainFunction(inputs, params);
end
function inputs = getSplines(inputs)
inputs.splineJointAngles = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointAngles', 0.0000001);
inputs.splineJointMoments = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointMoments', 0.0000001);
% inputs.splineRightGroundReactionForces = spaps(inputs.experimentalTime, ...
%     inputs.experimentalRightGroundReactions', 0.0000001);
% inputs.splineLeftGroundReactionForces = spaps(inputs.experimentalTime, ...
%     inputs.experimentalLeftGroundReactions', 0.0000001);
if strcmp(inputs.controllerType, 'synergy_driven')
inputs.splineMuscleActivations = spaps(inputs.experimentalTime, ...
    inputs.experimentalMuscleActivations', 0.0000001);
end
end
function inputs = checkInitialGuess(inputs)
if isfield(inputs.initialGuess, 'state')
    for i = 1 : inputs.numCoordinates
        for j = 1 : length(inputs.initialGuess.stateLabels)
            if strcmpi(inputs.coordinateNames(i), inputs.initialGuess.stateLabels(j))
                stateIndex(i) = j;
            end
        end 
    end
    inputs.initialGuess.state = inputs.initialGuess.state(:, [stateIndex ...
    stateIndex + inputs.numCoordinates stateIndex + inputs.numCoordinates * 2]);
end
if isfield(inputs.initialGuess, 'control')
    for i = 1 : inputs.numCoordinates
        for k = 1 : length(inputs.initialGuess.controlLabels)
            if strcmpi(inputs.coordinateNames(i), inputs.initialGuess.controlLabels(k))
                controlIndex(i) = k;
            end
        end 
    end
    inputs.initialGuess.control(:, 1:inputs.numCoordinates) = ...
        inputs.initialGuess.control(:, controlIndex);
end
if isfield(inputs.initialGuess, 'parameter')
    parameterIndex = zeros(length(inputs.synergyGroups), inputs.numMuscles);
    for i = 1 : length(inputs.synergyGroups)
        for j = 1 : inputs.numMuscles
            for k = 1 : length(inputs.synergyGroups{i}.muscleNames)
                if strcmpi(inputs.muscleNames(j), inputs.synergyGroups{i}.muscleNames(k))
                    if i <= 1 
                        parameterIndex(i, k) = j;
                    else
                        parameterIndex(i, k + length(inputs.synergyGroups{i}.muscleNames)) = j;
                    end
                end
            end
        end 
    end
    parameterTemp = [];
    numSynergiesIndex = 0;
    for j = 1 : length(inputs.synergyGroups)
        parameterTemp = cat(2, parameterTemp, ...
            reshape(inputs.initialGuess.parameter(1 + numSynergiesIndex: ...
            inputs.synergyGroups{j}.numSynergies + numSynergiesIndex, ...
            nonzeros(parameterIndex(j, :)))', 1, []));
        numSynergiesIndex = numSynergiesIndex + inputs.synergyGroups{j}.numSynergies;
    end
    inputs.initialGuess.parameter = parameterTemp;
end
if strcmp(inputs.controllerType, 'synergy_driven') 
    inputs = getMuscleSynergiesInitialGuess(inputs);
end
end
function inputs = getMuscleSynergiesInitialGuess(inputs)
if isfield(inputs.initialGuess,"parameter") 
    inputs.parameterGuess = inputs.initialGuess.parameter;
    synergyWeights = getSynergyWeightsFromGroups(inputs.parameterGuess, inputs);
    inputs.commandsGuess = inputs.experimentalMuscleActivations / synergyWeights;
else
    inputs.mtpActivationsColumnNames = inputs.muscleLabels;
    inputs.mtpActivations = permute(inputs.experimentalMuscleActivations, [3 2 1]);
    inputs.parameterGuess = prepareNonNegativeMatrixFactorizationInitialValues(inputs, inputs)';
    synergyWeights = getSynergyWeightsFromGroups(inputs.parameterGuess, inputs);
    inputs.commandsGuess = inputs.experimentalMuscleActivations / synergyWeights;
end
end