% This function is part of the NMSM Pipeline, see file for full license.
%
% Wrapper for splder() as published in C++ by Kelly Rooney and B.J. Fregly
%
% (1D Array of double, 2D Array of double, integer, double) -> (None)
% Calculates the derivative of the given gcvSpline at original time points

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

function derivative = calcGcvSplineDerivative(time, gcvSpline, degree)
IDER = 1;
X = time;
C = gcvSpline;
M = (degree + 1) / 2;
N = size(X, 2);
Q = ones(1, 2 * M);
derivative = zeros(1, length(X));
for i = 1:length(time)
    T = time(i);
    L = ceil(N * (T - X(1)) / (X(end) - X(1)));
    derivative(i) = splder(IDER, M, N, T, X, C, L, Q);
end