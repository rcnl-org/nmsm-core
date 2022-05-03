% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a string array of column names in order, a 1D array
% of time points and a 2D array of data. The first dimension of the 1D and
% 2D arrays must match.
%
% (Array of string, Array of double, matrix of double, string) -> (None)
% Print results of optimization to console or file

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

function writeToSto(columnLabels, timePoints, data, outfile)
import org.opensim.modeling.*
table = TimeSeriesTable();
table.setColumnLabels(stringArrayToStdVectorString(columnLabels));
for i=1:length(timePoints)
    table.appendRow(timePoints(i), doubleArrayToRowVector(data(i, :)))
end
STOFileAdapter.write(table, outfile)
end

