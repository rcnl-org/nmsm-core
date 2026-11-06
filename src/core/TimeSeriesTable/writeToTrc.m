% This function is part of the NMSM Pipeline, see file for full license.
%
% Writes marker data to a .trc file. Data has three columns (x, y, z) per
% marker, in the same order as markerNames. Missing samples may be NaN.
%
% (Array of string, Array of double, 2D Array of double, double, string,
% string) -> (None)
% Writes marker trajectories to a .trc file

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

function writeToTrc(markerNames, timePoints, data, dataRate, units, ...
    outfile)
import org.opensim.modeling.TRCFileAdapter
markerNames = string(markerNames);
if size(data, 2) ~= 3 * numel(markerNames)
    throw(MException("writeToTrc:sizeMismatch", ...
        "Data has %d columns but %d markers need %d.", size(data, 2), ...
        numel(markerNames), 3 * numel(markerNames)))
end
suffixes = ["_x" "_y" "_z"];
columnLabels = reshape((markerNames(:) + suffixes)', 1, []);
table = makeTimeSeriesTable(columnLabels, timePoints, data).packVec3( ...
    stringArrayToStdVectorString(suffixes));
table.addTableMetaDataString("DataRate", num2str(dataRate));
table.addTableMetaDataString("Units", char(units));
TRCFileAdapter().write(table, outfile);
end
