% This function is part of the NMSM Pipeline, see file for full license.
%
% This function fits muscle tendon lengths and moment arms as a 
% function of joint angles
%
% Inputs:
% jointAngles (numberFrames x degreesOfFreedom)
% muscleTendonLengths (numberFrames x 1)
% momentArms (numberFrames x degreesOfFreedom)
% polynomialDegree (value)
%
% (2D Number matrix, Number array, 2D Number matrix, Number) -> 
% (Symbol array, 2D Symbol array, Number array)
%
% returns muscle-specific polynomial expressions with corresponding 
% coefficients that best fit experimental muscle tendon lengths and 
% moment arms.

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

function [polynomialExpressionMuscleTendonLength, ...
    polynomialExpressionMomentArms, coefficients] = ...
    createMuscleSpecificSurrogateModel(jointAngles, ...
    muscleTendonLengths, momentArms, polynomialDegree)

% Get polynomial expressions for muscle tendon length and moment arms
[polynomialExpressionMuscleTendonLength, ...
    polynomialExpressionMomentArms, theta]  = ...
    getPolynomialExpressions(jointAngles, polynomialDegree);
% Get A matrix
matrix = getDataMatrix(polynomialExpressionMuscleTendonLength, ...
    polynomialExpressionMomentArms, jointAngles, theta);
% Create b vector
vector = cat(1, muscleTendonLengths, reshape(momentArms, [], 1));
% Calculate coefficients using linear least squares regression
coefficients = matrix \ vector;
end