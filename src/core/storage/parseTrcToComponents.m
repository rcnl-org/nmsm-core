% This function is part of the NMSM Pipeline, see file for full license.
%
% This function extracts the data of a .trc marker file to a vector of
% column names, a time column, and a 2D MATLAB array. Column names are
% expanded to markerName_x/y/z. The organization is column major. I.E.
% output(i,:) is the full time series for the i-th scalar column (x, y, or
% z component of one marker).
%
% (string) -> (Array of string, Array of double, 2D Array of double)
% Extracts components from .trc marker file.

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

function [columnNames, time, data] = parseTrcToComponents(trcFile)
import org.opensim.modeling.TimeSeriesTableVec3

timeSeriesTable = TimeSeriesTableVec3(trcFile);

% Extract marker names and expand to _x/_y/_z column names
labels = timeSeriesTable.getColumnLabels();
nMarkers = timeSeriesTable.getNumColumns();
columnNames = strings(1, nMarkers * 3);
for i = 0:nMarkers-1
    markerName = string(labels.get(i));
    columnNames(i*3 + 1) = markerName + "_x";
    columnNames(i*3 + 2) = markerName + "_y";
    columnNames(i*3 + 3) = markerName + "_z";
end

% Extract time column
timeCol = timeSeriesTable.getIndependentColumn();
nRow = timeSeriesTable.getNumRows();
time = zeros(1, nRow);
for i = 0:nRow-1
    time(i+1) = timeCol.get(i);
end

% Extract data column-major: data(i, :) is scalar time series for columnNames(i)
data = zeros(nMarkers * 3, nRow);
for i = 0:nRow-1
    row = timeSeriesTable.getRowAtIndex(i);
    for j = 0:nMarkers-1
        vec3 = row.get(j);
        data(j*3 + 1, i+1) = vec3.get(0);
        data(j*3 + 2, i+1) = vec3.get(1);
        data(j*3 + 3, i+1) = vec3.get(2);
    end
end
end
