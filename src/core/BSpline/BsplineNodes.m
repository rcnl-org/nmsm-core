% This function is part of the NMSM Pipeline, see file for full license.
%
% This function constructs B-spline nodes for specified time vector, spline
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

function [nodes] = BsplineNodes(time,q,degree,numNodes)

% Construct B-spline nodes for specified time vector, spline degree, and
% number of B-spline nodes, assuming the initial curve to be fitted is
% a zero vector of the same length as the time vector.
numPts = length(time);
interval = time(2)-time(1);
[N,~,~] = BSplineMatrices(degree,numNodes,numPts,interval);
% [N] = BSplineMatrix(degree,numNodes,numPts);
% Note that the interval setting is only needed to calculate first and
% second derivatives correctly.

% Calculate B-spline nodes that best fit the original curve using linear
% least squares.
nodes = N\q;

end
