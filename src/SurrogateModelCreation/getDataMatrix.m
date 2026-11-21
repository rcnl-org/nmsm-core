% This function is part of the NMSM Pipeline, see file for full license.
%
% This function creates the A matrix containing the joint angles in
% the same order as the polynomial expression
%
% Inputs:
% polynomialExpressionMuscleTendonLength (1 x numberOfCoefficients)
% polyninomialExpressionMomentArms (degreesOfFreedom x numberOfCoefficients)
% jointAngles (numberFrames x degreesOfFreedom)
% theta (1 x degreesOfFreedom
%
% (Symbol array, 2D Symbol array, 2D Number matrix, Symbol array) -> 
% (2D Number matrix)
%
% returns A matrix

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
% -----------------------------------------------------------------------

function matrix = getDataMatrix(polynomialExpressionMuscleTendonLength, ...
    polyninomialExpressionMomentArms, jointAngles, theta)

% Convert symbolic expressions to a numeric function of the joint angles
expressionsFunction = matlabFunction( ...
    [polynomialExpressionMuscleTendonLength; ...
    polyninomialExpressionMomentArms], 'Vars', {theta}, 'Optimize', false);
% Evaluate symbolic expressions for muscle tendon lengths and moment arms
expressions = zeros(size(polyninomialExpressionMomentArms, 1) + 1, ...
    size(polyninomialExpressionMomentArms, 2), size(jointAngles, 1));
for i = 1 : size(jointAngles, 1)
    expressions(:, :, i) = expressionsFunction(jointAngles(i, :));
end
muscleTendonLengthMatrix = permute(expressions(1, :, :), [3 2 1]);
momentArmsMatrix = permute(expressions(2 : end, :, :), [3 1 2]);
% Create A matrix
matrix = [muscleTendonLengthMatrix; reshape(momentArmsMatrix, ...
    [], size(polyninomialExpressionMomentArms, 2))];
end