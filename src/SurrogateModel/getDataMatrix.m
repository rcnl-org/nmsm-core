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

% Populate symbolic theta(s) with actual data
for i = 1 : size(jointAngles, 2)
    eval(['theta' num2str(i) ' = jointAngles(:,' num2str(i) ');']);
end
% Evaluate symbolic expressions for muscle tendon lengths and moment arms
for j = 1 : size(polyninomialExpressionMomentArms, 2)
    muscleTendonLengthMatrix(:, j) = ...
        eval(polynomialExpressionMuscleTendonLength(1, j)) .* ...
        ones(size(jointAngles, 1), 1);
    for k = 1 : size(jointAngles, 2)
        momentArmsMatrix(:, k, j) = ...
            eval(polyninomialExpressionMomentArms(k, j)) .* ...
            ones(size(jointAngles, 1), 1);
    end                 
end
% Create A matrix
matrix = [muscleTendonLengthMatrix; reshape(momentArmsMatrix, ...
    [], size(polyninomialExpressionMomentArms, 2))];
end