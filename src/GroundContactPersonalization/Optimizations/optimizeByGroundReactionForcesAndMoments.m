% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function inputs = ...
    optimizeByGroundReactionForcesAndMoments(inputs, ...
    params)
[initialValues, fieldNameOrder] = makeInitialValues(inputs, ...
    params);
[lowerBounds, upperBounds] = makeBounds(inputs, params);
optimizerOptions = prepareOptimizerOptions(params);
results = lsqnonlin(@(values) calcGroundReactionForcesAndMomentsCost(values, ...
    fieldNameOrder, inputs, params), initialValues, lowerBounds, ...
    upperBounds, optimizerOptions);
inputs = mergeGroundContactPersonalizationRoundResults(inputs, results, ...
    params, 3);
end

% (struct, struct) -> (Array of double, Array of string)
% generate initial values to be optimized from inputs, params
function [initialValues, fieldNameOrder] = makeInitialValues( ...
    inputs, params)
initialValues = [];
fieldNameOrder = [];
if (params.stageThree.springConstants.isEnabled)
    initialValues = [initialValues inputs.springConstants];
    fieldNameOrder = [fieldNameOrder "springConstants"];
end
if (params.stageThree.dampingFactors.isEnabled)
    initialValues = [initialValues inputs.dampingFactors];
    fieldNameOrder = [fieldNameOrder "dampingFactors"];
end
if (params.stageThree.bSplineCoefficients.isEnabled)
    initialValues = [initialValues ...
        reshape(inputs.bSplineCoefficients, 1, [])];
    fieldNameOrder = [fieldNameOrder "bSplineCoefficients"];
end
if (params.stageThree.dynamicFrictionCoefficient.isEnabled)
    initialValues = [initialValues valueOrAlternate(params, ...
        "initialDynamicFrictionCoefficient", 1)];
    fieldNameOrder = [fieldNameOrder "dynamicFrictionCoefficient"];
end
end

% (struct) -> (Array of double, Array of double)
% Generate lower and upper bounds for design variables from inputs
function [lowerBounds, upperBounds] = makeBounds(inputs, params)
lowerBounds = [];
upperBounds = [];
if (params.stageThree.springConstants.isEnabled)
    lowerBounds = [lowerBounds zeros(1, length(inputs.springConstants))];
    upperBounds = [upperBounds Inf(1, length(inputs.springConstants))];
end
if (params.stageThree.dampingFactors.isEnabled)
    lowerBounds = [lowerBounds zeros(1, length(inputs.dampingFactors))];
    upperBounds = [upperBounds Inf(1, length(inputs.dampingFactors))];
end
if (params.stageThree.bSplineCoefficients.isEnabled)
    lowerBounds = [lowerBounds -Inf(1, length(reshape(...
        inputs.bSplineCoefficients, 1, [])))];
    upperBounds = [upperBounds Inf(1, length(reshape(...
        inputs.bSplineCoefficients, 1, [])))];
end
if (params.stageThree.dynamicFrictionCoefficient.isEnabled)
    lowerBounds = [lowerBounds 0];
    upperBounds = [upperBounds Inf];
end
end

% (struct) -> (struct)
% Prepare params for outer optimizer for Kinematic Calibration
function output = prepareOptimizerOptions(params)
output = optimoptions('lsqnonlin', 'UseParallel', true);
output.DiffMinChange = valueOrAlternate(params, 'diffMinChange', 1e-4);
output.OptimalityTolerance = valueOrAlternate(params, ...
    'optimalityTolerance', 1e-6);
output.FunctionTolerance = valueOrAlternate(params, ...
    'functionTolerance', 1e-6);
output.StepTolerance = valueOrAlternate(params, ...
    'stepTolerance', 1e-4);
output.MaxFunctionEvaluations = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 3e6);
output.Display = valueOrAlternate(params, ...
    'display','iter');
end