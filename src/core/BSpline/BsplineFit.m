% This function is part of the NMSM Pipeline, see file for full license.
%
% Fits a B-spline curve to a set of data points.
%
% (array of num, array of num, num, num) => (2d mat, 2d mat, 2d mat)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Benjamin J. Fregly                                           %
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

function [qFit,qpFit,qppFit] = BsplineFit(time,q,degree,numNodes)

% Create B-spline matrices for specified spline degree, number of B-spline
% nodes, and number of data points.
numPts = length(time);
interval = time(2)-time(1);
[N, Np, Npp] = BSplineMatrices(degree,numNodes,numPts,interval);
% [N] = BSplineMatrix(degree,numNodes,numPts);
% Note that the interval setting is only needed to calculate first and
% second derivatives correctly.

% Calculate B-spline nodes that best fit the original curve using linear
% least squares.
Nodes = N\q;

% Now reconstruct the parameterized curve and its first and second
% derivatives using the calculated B-spline matrices and nodes.
qFit = N*Nodes;
qpFit = Np*Nodes;
qppFit = Npp*Nodes;
