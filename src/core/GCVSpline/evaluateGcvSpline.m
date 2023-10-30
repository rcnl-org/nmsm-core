% This function is part of the NMSM Pipeline, see file for full license.
%
% Evaluates a GCV spline for its fitted values or a derivative at a set of
% time points. The spline to evaluate is chosen by the given column label,
% which can be provided as either an integer (the raw index in the spline
% set) or a string defining a column label that should exist in the spline
% set. The derivative level is given as an integer (0 for position, 1 for
% velocity, 2 for acceleration, etc.). 
%
% (GCVSplineSet, string OR int, Array of double, int) -> (Array of double)
% Evaluate GCV spline values or derivatives at a set of time points.

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

function values = evaluateGcvSpline(splineSet, columnLabel, time, ...
    derivative)
values = zeros(1, length(time));

if isstring(columnLabel) || ischar(columnLabel)
    columnLabel = splineSet.getIndex(columnLabel);
    assert(index > -1, "The specified coordinate is not included in" + ...
        " the spline set.")
end

if nargin < 4
    derivative = 0;
end

for i = 1 : length(time)
    values(i) = splineSet.evaluate(columnLabel, derivative, time(i));
end
end
