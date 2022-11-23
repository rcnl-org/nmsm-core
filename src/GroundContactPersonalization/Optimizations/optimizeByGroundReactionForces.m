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

function inputs = optimizeByGroundReactionForces(inputs, params)
[initialValues, fieldNameOrder] = makeInitialValues(inputs, ...
    params);
[lowerBounds, upperBounds] = makeBounds(inputs);
optimizerOptions = prepareOptimizerOptions(params);
results = lsqnonlin(@(values) calcGroundReactionCost(values, ...
    fieldNameOrder, inputs, params), initialValues, lowerBounds, ...
    upperBounds, optimizerOptions);
inputs = mergeGroundContactPersonalizationRoundResults(inputs, results, 2);
end

% (struct, struct) -> (Array of double)
% generate initial values to be optimized from inputs, params
function [initialValues, fieldNameOrder] = makeInitialValues( ...
    inputs, params)
initialValues = [inputs.springConstants inputs.dampingFactors];
initialValues = [initialValues ...
    reshape(inputs.bSplineCoefficients, 1, [])];
initialValues = [initialValues valueOrAlternate(params, ...
    "staticFrictionCoefficientErrorCenter", 0.25)];
initialValues = [initialValues valueOrAlternate(params, ...
    "dynamicFrictionCoefficientErrorCenter", 0.2)];
initialValues = [initialValues valueOrAlternate(params, ...
    "viscousFrictionCoefficientErrorCenter", 0.005)];
fieldNameOrder = ["springConstants", "dampingFactors", ...
    "bSplineCoefficients", "staticFrictionCoefficient", ...
    "dynamicFrictionCoefficient", "viscousFrictionCoefficient"];
end

% (struct) -> (Array of double, Array of double)
% Generate lower and upper bounds for design variables from inputs
function [lowerBounds, upperBounds] = makeBounds(inputs)
lowerBounds = zeros(1, length(inputs.springConstants));
lowerBounds = [lowerBounds zeros(1, length(inputs.dampingFactors))];
lowerBounds = [lowerBounds -Inf(1, length(reshape(...
    inputs.bSplineCoefficients, 1, [])))];
lowerBounds = [lowerBounds 0 0 0];
upperBounds = Inf(1, length(inputs.springConstants));
upperBounds = [upperBounds Inf(1, length(inputs.dampingFactors))];
upperBounds = [upperBounds Inf(1, length(reshape(...
    inputs.bSplineCoefficients, 1, [])))];
upperBounds = [upperBounds Inf Inf Inf];
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
    'stepTolerance', 1e-6);
output.MaxFunctionEvaluations = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 3e6);
output.Display = valueOrAlternate(params, ...
    'display','iter');
end
