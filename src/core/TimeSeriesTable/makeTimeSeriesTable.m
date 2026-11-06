% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds an OpenSim TimeSeriesTable from a string array of column labels,
% an array of time points, and a 2D array of data (time x columns). The
% data are passed to OpenSim as one matrix rather than one value at a time,
% which is much faster for long trials such as analog data.
%
% (Array of string, Array of double, 2D Array of double) -> (TimeSeriesTable)
% Returns a TimeSeriesTable holding the given data

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function table = makeTimeSeriesTable(columnLabels, timePoints, data)
import org.opensim.modeling.TimeSeriesTable
import org.opensim.modeling.StdVectorDouble
import org.opensim.modeling.Matrix
if size(data, 1) ~= length(timePoints)
    throw(MException("makeTimeSeriesTable:sizeMismatch", ...
        "Data has %d rows but there are %d time points.", ...
        size(data, 1), length(timePoints)))
end
times = StdVectorDouble();
for i = 1:length(timePoints)
    times.add(timePoints(i));
end
table = TimeSeriesTable(times, Matrix.createFromMat(data), ...
    stringArrayToStdVectorString(columnLabels));
end
