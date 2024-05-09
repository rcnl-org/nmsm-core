% This function is part of the NMSM Pipeline, see file for full license.
%
% This function extracts the data of the OpenSim Storage object to a 2D
% MATLAB array. The organization is column major. I.E. output(0,:) is the
% first column of the Storage (not including the time column)
%
% (Storage) -> (2D Array of double) 
% Extracts 2D double Array from Storage object

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function output = storageToDoubleMatrix(storage)
import org.opensim.modeling.ArrayDouble

if(class(storage) ~= "org.opensim.modeling.Storage")
    storage = org.opensim.modeling.Storage(storage);
end

nCol = storage.getColumnLabels().size()-1;
nRow = storage.getSize();

output = zeros(nCol, nRow);
col = ArrayDouble();
for i=1:nCol
    storage.getDataColumn(i-1, col);
    output(i, :) = arrayDoubleToDoubleArray(col);
end
end

