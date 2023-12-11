% This function is part of the NMSM Pipeline, see file for full license.
%
% Fit data with a GCVSplineSet, a set of GCV splines defined by the OpenSim
% API. The arguments represent a time column, data to fit, column labels,
% the degree of splines to fit, and a smoothing parameter. The first three
% arguments are required, and the last two are optional, defaulting to
% degree 5 and no smoothing. 
%
% (Array of double, 2D Array of double, Array of string, int, double) -> 
% (GCVSplineSet)
%
% Fit data with a set of GCV splines.

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

function splineSet = makeGcvSplineSet(time, data, columnLabels, degree, ...
    smoothingParameter)
import org.opensim.modeling.*

if length(time) ~= size(data, 1)
    data = data';
end
assert(length(time) == size(data, 1), "Length of time column must" + ...
    " equal number of frames of data to spline-fit.")
assert(length(columnLabels)==size(data, 2), "Number of column labels" + ...
    " must match number of data columns to spline-fit.")

timeVec = StdVectorDouble(time);
matrix = Matrix.createFromMat(data);
labels = StdVectorString(columnLabels);
table = TimeSeriesTable(timeVec, matrix, labels);

if nargin < 4
    degree = 5;
elseif isempty(degree)
    degree = 5;
end

if nargin < 5
    smoothingParameter = 0;
elseif isempty(smoothingParameter)
    smoothingParameter = 0;
end

splineSet = GCVSplineSet(table, labels, degree, smoothingParameter);
end
