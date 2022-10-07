% This function is part of the NMSM Pipeline, see file for full license.
%
% Wrapper for gcvspl() as published in C++ by Kelly Rooney and B.J. Fregly
%
% (1D Array of double, 2D Array of double, integer, double) -> (None)
% Calculates the coefficients for the given data as a GCV Spline

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

function coefficients = calcGcvSpline(time, data, degree, cutoffFrequency)
X  = time;
Y = data;
NY = size(X, 1);
WX = ones(size(X, 2), 1);
WY = ones(size(Y, 1), 1);
M = (degree + 1) / 2;
N = size(X, 2);
K = size(Y, 1);
MD = 2;
samplingFrequency = length(X)/(X(end) - X(1));
VAL = (samplingFrequency / 1000.0) / power( 2 * pi * cutoffFrequency / ...
    1000.0 / power ((sqrt(2.0) - 1), 0.5 / M ), 2.0 * M );
NC = N * K;
coefficients = gcvspl(X, Y, NY, WX, WY, M, N, K, MD, VAL, NC);
end