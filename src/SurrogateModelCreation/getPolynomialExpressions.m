% This function is part of the NMSM Pipeline, see file for full license.
%
% This function creates muscle-specific symbolic polynomial expressions for  
% muscle tendon length and moment arms.
%
% Inputs:
% jointAngles (numberFrames x degreesOfFreedom)
% polynomialDegree (value)
%
% (2D Number matrix, Number) -> (Symbol array, 2D Symbol matrix)
%
% returns muscle-specific polynomial expressions based on polynomial
% degree and the number of degrees of freedom.

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
    polynomialExpressionMuscleTendonVelocities, ...
    polynomialExpressionMomentArms, theta] = ...
    getPolynomialExpressions(jointAngles, polynomialDegree)

% Initialize symbolic thetas
theta = sym('theta', [1 size(jointAngles, 2)]);
thetaDot = sym('thetaDot', [1 size(jointAngles, 2)]);
% Create polynomial basis function
basisFunction = 1;
for i = 1 : size(jointAngles, 2)
    basisFunction = theta(i) + basisFunction;
end
% Approx. muscle tendon length using polynomial basis equation to nth degree
polynomialExpressionMuscleTendonLength = basisFunction .^ polynomialDegree;
% Reformate polynomial expression
polynomialExpressionMuscleTendonLength = ...
    children(expand(polynomialExpressionMuscleTendonLength));
polynomialExpressionMuscleTendonLength = ...
    cat(2, polynomialExpressionMuscleTendonLength{:});
% Remove all coefficients
for i = 1 : size(polynomialExpressionMuscleTendonLength, 2)
    polynomialExpressionMuscleTendonLength(i) = ...
        polynomialExpressionMuscleTendonLength(i) / ...
        coeffs(polynomialExpressionMuscleTendonLength(i)); 
end
% Differentiate -muscle tendon length w.r.t. associated joint angle
for i = 1 : size(jointAngles, 2)
    polynomialExpressionMomentArms(i, :) = ...
        diff(-polynomialExpressionMuscleTendonLength, theta(i));
end
% Differentiate muscle tendon length w.r.t. time using the chain rule,
% dL/dt = sum(dL/dtheta * thetaDot) = -sum(momentArm * thetaDot)
polynomialExpressionMuscleTendonVelocities = ...
    -thetaDot * polynomialExpressionMomentArms;
end