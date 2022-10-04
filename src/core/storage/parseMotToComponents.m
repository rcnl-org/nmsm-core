% This function is part of the NMSM Pipeline, see file for full license.
%
% This function extracts the data of an OpenSim Storage object loaded from
% a .mot file to a vector of column names, a time column, and a 2D MATLAB
% array containing data converted to radians if necessary, using a Model to
% analyze coordinates. The organization is column major. I.E. output(0,:)
% is the first column of the Storage (not including the time column).
%
% (Model, Storage) -> (Array of string, Array of double, ...
%                       2D Array of double)
% Extracts components from .mot Storage object.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2022 Rice University and the Authors                      %
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

function [columnNames, time, data] = parseMotToComponents(model, storage)
import org.opensim.modeling.ArrayDouble

columnNames = getStorageColumnNames(storage);
time = findTimeColumn(storage);
coordinates = model.getCoordinateSet();

nRow = storage.getSize();
isInDegrees = storage.isInDegrees();

data = zeros(length(columnNames), nRow);
col = ArrayDouble();
for i=1:length(columnNames)
    storage.getDataColumn(i-1, col);
    data(i, :) = arrayDoubleToDoubleArray(col);
    try
        if (isInDegrees && coordinates.get(columnNames(i)). ...
                getMotionType().toString().toCharArray()' == "Rotational")
            data(i, :) = deg2rad(data(i, :));
        end
    catch;end
end
end