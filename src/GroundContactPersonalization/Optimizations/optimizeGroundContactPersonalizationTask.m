% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct, double) -> (struct)
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

function inputs = optimizeGroundContactPersonalizationTask(inputs, ...
    params, task)
[initialValues, fieldNameOrder] = makeInitialValues(inputs, ...
    params, task);
[lowerBounds, upperBounds] = makeBounds(inputs, params, task);
optimizerOptions = prepareOptimizerOptions(params);
clear calcGroundContactPersonalizationTaskCost
results = lsqnonlin(@(values) calcGroundContactPersonalizationTaskCost( ...
    values, fieldNameOrder, inputs, params, task), initialValues, ...
    lowerBounds, upperBounds, optimizerOptions);
inputs = mergeGroundContactPersonalizationRoundResults(inputs, results, ...
    params, task);
end

% (struct, struct) -> (Array of double, Array of string)
% Generate initial values to be optimized from inputs and params. The
% fieldNameOrder allows tracking of included design variables for
% rebuilding a struct of design variables inside the cost function. 
function [initialValues, fieldNameOrder] = makeInitialValues( ...
    inputs, params, task)
initialValues = [];
fieldNameOrder = [];
if (params.tasks{task}.designVariables(1))
    initialValues = [initialValues 0.001 * inputs.springConstants];
    fieldNameOrder = [fieldNameOrder "springConstants"];
end
if (params.tasks{task}.designVariables(2))
    initialValues = [initialValues inputs.dampingFactor];
    fieldNameOrder = [fieldNameOrder "dampingFactor"];
end
if (params.tasks{task}.designVariables(3))
    initialValues = [initialValues inputs.dynamicFrictionCoefficient];
    fieldNameOrder = [fieldNameOrder "dynamicFrictionCoefficient"];
end
if (params.tasks{task}.designVariables(4))
    initialValues = [initialValues inputs.viscousFrictionCoefficient];
    fieldNameOrder = [fieldNameOrder "viscousFrictionCoefficient"];
end
if (params.tasks{task}.designVariables(5))
    initialValues = [initialValues inputs.restingSpringLength];
    fieldNameOrder = [fieldNameOrder "restingSpringLength"];
end
if (params.tasks{task}.designVariables(6))
    for foot = 1:length(inputs.surfaces)
        initialValues = [initialValues ...
            reshape(inputs.surfaces{foot}.bSplineCoefficients, 1, [])];
        fieldNameOrder = [fieldNameOrder ("bSplineCoefficients" + foot)];
    end
end
if (params.tasks{task}.designVariables(7))
    for foot = 1:length(inputs.surfaces)
        initialValues = [initialValues ...
            inputs.surfaces{foot}.electricalCenterShiftX];
        fieldNameOrder = [fieldNameOrder ("electricalCenterX" + foot)];
    end
end
if (params.tasks{task}.designVariables(8))
    for foot = 1:length(inputs.surfaces)
        initialValues = [initialValues ...
            inputs.surfaces{foot}.electricalCenterShiftY];
        fieldNameOrder = [fieldNameOrder ("electricalCenterY" + foot)];
    end
end
if (params.tasks{task}.designVariables(9))
    for foot = 1:length(inputs.surfaces)
        initialValues = [initialValues ...
            inputs.surfaces{foot}.electricalCenterShiftZ];
        fieldNameOrder = [fieldNameOrder ("electricalCenterZ" + foot)];
    end
end
if (params.tasks{task}.designVariables(10))
    for foot = 1:length(inputs.surfaces)
        initialValues = [initialValues ...
            inputs.surfaces{foot}.forcePlateRotation];
        fieldNameOrder = [fieldNameOrder ("forcePlateRotation" + foot)];
    end
end
end

% (struct) -> (Array of double, Array of double)
% Generate lower and upper bounds for design variables from inputs
function [lowerBounds, upperBounds] = makeBounds(inputs, params, task)
lowerBounds = [];
upperBounds = [];
if (params.tasks{task}.designVariables(1))
    lowerBounds = [lowerBounds zeros(1, length(inputs.springConstants))];
    upperBounds = [upperBounds Inf(1, length(inputs.springConstants))];
end
if (params.tasks{task}.designVariables(2))
    lowerBounds = [lowerBounds 0];
    upperBounds = [upperBounds Inf];
end
if (params.tasks{task}.designVariables(3))
    lowerBounds = [lowerBounds 0];
    upperBounds = [upperBounds Inf];
end
if (params.tasks{task}.designVariables(4))
    lowerBounds = [lowerBounds 0];
    upperBounds = [upperBounds Inf];
end
if (params.tasks{task}.designVariables(5))
    lowerBounds = [lowerBounds -Inf];
    upperBounds = [upperBounds Inf];
end
if (params.tasks{task}.designVariables(6))
    for foot = 1:length(inputs.surfaces)
        lowerBounds = [lowerBounds -Inf(1, length(reshape(...
            inputs.surfaces{foot}.bSplineCoefficients, 1, [])))];
        upperBounds = [upperBounds Inf(1, length(reshape(...
            inputs.surfaces{foot}.bSplineCoefficients, 1, [])))];
    end
end
if (params.tasks{task}.designVariables(7))
    for foot = 1:length(inputs.surfaces)
        lowerBounds = [lowerBounds -Inf];
        upperBounds = [upperBounds Inf];
    end
end
if (params.tasks{task}.designVariables(8))
    for foot = 1:length(inputs.surfaces)
        lowerBounds = [lowerBounds -Inf];
        upperBounds = [upperBounds Inf];
    end
end
if (params.tasks{task}.designVariables(9))
    for foot = 1:length(inputs.surfaces)
        lowerBounds = [lowerBounds -Inf];
        upperBounds = [upperBounds Inf];
    end
end
if (params.tasks{task}.designVariables(10))
    for foot = 1:length(inputs.surfaces)
        lowerBounds = [lowerBounds -0.2618]; % 15 degrees
        upperBounds = [upperBounds 0.2618];
    end
end
end

% (struct) -> (struct)
% Prepare optimizer options for lsqnonlin. 
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
output.MaxIterations = valueOrAlternate(params, 'maxIterations', 400);
output.Display = valueOrAlternate(params, ...
    'display','iter');
end
