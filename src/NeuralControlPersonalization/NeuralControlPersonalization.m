% This function is part of the NMSM Pipeline, see file for full license.
%
% Neural Control Personalization uses movement and EMG data to personalize
% the muscle characteristics of the patient.
%
% inputs:
%   - model (string)
%   - jointMoment (3D array)
%   - muscleTendonLength (3D array)
%   - muscleTendonVelocity (3D array)
%   - muscleTendonMomentArm (4D array)
%   - emgData (3D array)
%   - experimentalData (struct) - see costFunction
%
% (struct, struct) -> (struct)
% Runs the Muscle Tendon Personalization algorithm

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

function [finalValues, inputs] = NeuralControlPersonalization(inputs, ...
    params)
verifyInputs(inputs); % (struct) -> (None)
%verifyParams(params); % (struct) -> (None)
params = finalizeParams(params);
inputs = finalizeInputs(inputs);
initialValues = prepareInitialValues(inputs);
if params.useCasadi
    [finalValues, inputs] = ...
        computeNeuralControlOptimizationWithCasadi(initialValues, ...
        inputs, params);
else
    finalValues = computeNeuralControlOptimization(initialValues, ...
        inputs, params);
end
end

% (struct) -> (None)
% throws an error if any of the inputs are invalid
function verifyInputs(inputs)
verifyNoDuplicateMusclesBetweenSynergyGroups(inputs.synergyGroups);
end

% (struct) -> (None)
% throws an error if the parameter is included but is not of valid type
function verifyParams(params)
if(isfield(params, 'maxIterations'))
    verifyParam(params, 'maxIterations', @verifyNumeric, ...
        'param maxFunctionEvaluations is not a number');
end
if(isfield(params, 'maxFunctionEvaluations'))
    verifyParam(params, 'maxFunctionEvaluations', @verifyNumeric, ...
        'param maxFunctionEvaluations is not a number');
end
end


function inputs = finalizeInputs(inputs)
inputs.numNodes = valueOrAlternate(inputs, "numNodes", 21);
inputs.numPoints = valueOrAlternate(inputs, "numPoints", ...
    size(inputs.muscleTendonLength, 3));
inputs.vMaxFactor = valueOrAlternate(inputs, "vMaxFactor", 10);
inputs.numMuscles = 0;
inputs.numSynergies = 0;
for i = 1 : length(inputs.synergyGroups)
    inputs.numMuscles = inputs.numMuscles + ...
    length(inputs.synergyGroups{i}.muscleNames);
    inputs.numSynergies = inputs.numSynergies + ...
    inputs.synergyGroups{i}.numSynergies;
end
inputs.numTrials = size(inputs.momentArms, 1);
end

function params = finalizeParams(params)
params.activationGroups = valueOrAlternate(params, "activationGroups", ...
    {});
params.normalizedFiberLengthGroups = valueOrAlternate(params, ...
    "normalizedFiberLengthGroups", {});
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
% extract initial version of optimized values from inputs/params
function values = prepareInitialValues(inputs)
values = [];
for i = 1:length(inputs.synergyGroups)
    values = [values; 0.01 * ...
        ones(inputs.synergyGroups{i}.numSynergies * ...
        length(inputs.synergyGroups{i}.muscleNames), 1)];
end
values = [values; ones(inputs.numSynergies * ...
    inputs.numNodes * inputs.numTrials, 1)];
end
