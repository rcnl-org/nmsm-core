% This function is part of the NMSM Pipeline, see file for full license.
%
% Neural Control Personalization finds a small set of muscle synergies
% (weights and B-spline-parameterized commands) whose combination best
% reproduces tracked joint moments and/or muscle activations, subject
% to a per-synergy normalization constraint (and, optionally, a hard
% bilateral-symmetry constraint between two synergy groups).
%
% (struct, struct) -> (Array of number, struct)
% Runs the Neural Control Personalization algorithm

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
if ~inputs.optimize_synergy_vectors
    packed = repackDesignVariables(inputs.fixedSynergyWeights, ...
        zeros(inputs.numTrials, inputs.numNodes, inputs.numSynergies), ...
        inputs);
    inputs.fixedSynergyVectorFlat = packed(1:sum(inputs.numWeightsPerGroup));
end
initialValues = prepareNcpInitialValues(inputs, params);
finalValues = computeNeuralControlOptimization(initialValues, inputs, ...
    params);
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
        'param maxIterations is not a number');
end
if(isfield(params, 'maxFunctionEvaluations'))
    verifyParam(params, 'maxFunctionEvaluations', @verifyNumeric, ...
        'param maxFunctionEvaluations is not a number');
end
end


function inputs = finalizeInputs(inputs)
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
inputs.numWeightsPerGroup = cellfun( ...
    @(g) g.numSynergies * length(g.muscleNames), inputs.synergyGroups);
inputs.numTrials = size(inputs.momentArms, 1);

% BJ's Runboh Bspline + precompute matrix, replace MATLAB spline because:
% Compatible with Auto Diff; won't create negative values; faster
degree = 3;
percent = linspace(0, 100, inputs.numPoints).';
interval = percent(2) - percent(1);
[Bmatrix, ~, ~] = BSplineMatrices(degree, inputs.numNodes, ...
    inputs.numPoints, interval);
inputs.Bmatrix = Bmatrix;
inputs.invBmatrix = pinv(Bmatrix);

[inputs.normalizedFiberLengths, inputs.normalizedFiberVelocities] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities( ...
    inputs, inputs.optimalFiberLengthScaleFactors, ...
    inputs.tendonSlackLengthScaleFactors);
end

function params = finalizeParams(params)
params.activationGroups = valueOrAlternate(params, "activationGroups", ...
    {});
params.normalizedFiberLengthGroups = valueOrAlternate(params, ...
    "normalizedFiberLengthGroups", {});
end