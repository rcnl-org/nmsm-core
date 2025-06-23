% This function is part of the NMSM Pipeline, see file for full license.
%
% This function evaluates a surrogate model using polynomials and
% coefficents. This function is only intended to be used as a saved
% function handle, with one handle saved for each surrogate muscle. The
% polynomials and coefficients belonging to each muscle are stored in the
% handle.
%
% (2D Array of double, 2D Array of double, Array of symbol,
% Array of symbol, 2D Array of symbol, 2D Array of double) ->
% (Array of double, Array of double, 2D Array of double)
%
% Evaluates the surrogate model for a single muscle.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [muscleTendonLength, muscleTendonVelocity, momentArms] = ...
    evaluateSurrogate(jointAngles, jointVelocities, ...
    polynomialExpressionMuscleTendonLength, ...
    polynomialExpressionMuscleTendonVelocity, ...
    polynomialExpressionMomentArms, coefficients, numArgs)

if isa(jointAngles, 'casadi.MX')
    muscleTendonLength = casadi.MX.zeros(size(jointAngles, 1), 1);
    muscleTendonVelocity = casadi.MX.zeros(size(jointAngles, 1), 1);
    momentArms = casadi.MX.zeros(size(jointAngles)).';
else
    muscleTendonLength = zeros(size(jointAngles, 1), 1);
    muscleTendonVelocity = zeros(size(jointAngles, 1), 1);
    momentArms = zeros(size(jointAngles)).';
end

for i = 1 : size(jointAngles, 1)
    positionArgs = jointAngles(i, :);
    velocityArgs = [positionArgs jointVelocities(i, :)];
    muscleTendonLength(i) = variableArgFn(polynomialExpressionMuscleTendonLength, positionArgs, numArgs(1)) * coefficients;
    muscleTendonVelocity(i) = variableArgFn(polynomialExpressionMuscleTendonVelocity, velocityArgs, numArgs(2)) * coefficients;
    momentArms(:, i) = variableArgFn(polynomialExpressionMomentArms, positionArgs, numArgs(3)) * coefficients;
end

momentArms = momentArms.';
end

function output = variableArgFn(fn, thetas, numArgs)
if numArgs == 1
    output = fn(thetas(1));
elseif numArgs == 2
    output = fn(thetas(1), thetas(2));
elseif numArgs == 3
    output = fn(thetas(1), thetas(2), thetas(3));
elseif numArgs == 4
    output = fn(thetas(1), thetas(2), thetas(3), thetas(4));
elseif numArgs == 5
    output = fn(thetas(1), thetas(2), thetas(3), thetas(4), thetas(5));
elseif numArgs == 6
    output = fn(thetas(1), thetas(2), thetas(3), thetas(4), thetas(5), thetas(6));
elseif numArgs == 7
    output = fn(thetas(1), thetas(2), thetas(3), thetas(4), thetas(5), thetas(6), thetas(7));
elseif numArgs == 8
    output = fn(thetas(1), thetas(2), thetas(3), thetas(4), thetas(5), thetas(6), thetas(7), thetas(8));
elseif numArgs == 9
    output = fn(thetas(1), thetas(2), thetas(3), thetas(4), thetas(5), thetas(6), thetas(7), thetas(8), thetas(9));
elseif numArgs == 10
    output = fn(thetas(1), thetas(2), thetas(3), thetas(4), thetas(5), thetas(6), thetas(7), thetas(8), thetas(9), thetas(10));
else
    temp = num2cell(thetas);
    output = fn(temp{:});
end
end

