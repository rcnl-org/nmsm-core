% This function is part of the NMSM Pipeline, see file for full license.
%
% Kinematic Calibration takes a model and applies a calibration.
%
% (Model, Array, Array, number, struct) -> (Model)
% Creates calibrated model from joint structure and marker plate structure

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

function optimizedValues = computeKinematicCalibration(model, ...
    markerFileName, functions, desiredError, params)
params.desiredError = desiredError; %required arg, but passed in params
optimizerOptions = prepareOptimizerOptions(params); % Prepare optimizer
initialValues = prepareKinematicCalibrationInitialValues(functions, ...
    params);
[lowerBounds, upperBounds] = prepareKinematicCalibrationBounds( ...
    initialValues, params);
clear computeInnerOptimization
clear calculateFrameSquaredError
optimizedValues = lsqnonlin ...
    (@(values) computeInnerOptimization(values, functions, model, ...
    markerFileName, params), initialValues, lowerBounds, upperBounds, ...
    optimizerOptions);
end

% (cellArray, struct) -> (array)
% Creates an array of initial values of same length as 1D cellArray
function output = prepareKinematicCalibrationInitialValues(functions, ...
    params)
output = valueOrAlternate(params, 'initialValues', ...
    zeros(max(size(functions)),1));
end

% (cell array, array, struct) -> (array, array)
% Returns the bounds of the KinCal or default bounds around initial values
function [lowerBounds, upperBounds] = prepareKinematicCalibrationBounds(...
    initialValues, params)
lowerBounds = valueOrAlternate(params, 'lowerBounds', ...
    initialValues - 10); 
upperBounds = valueOrAlternate(params, 'upperBounds', ...
    initialValues + 10);
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
    'maxFunctionEvaluations', 3e3);
output.MaxIterations = valueOrAlternate(params, ...
    'maxIterations', 4e6);
output.Display = valueOrAlternate(params, ...
    'display','iter');
output.FiniteDifferenceType = 'central';
end

