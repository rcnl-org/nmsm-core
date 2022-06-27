% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (string) -> (MarkersReference)
% Makes a MarkersReference from a given model and parameters

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

function markersReference = MarkersReference(fileName)
import org.opensim.modeling.TimeSeriesTableVec3
import org.opensim.modeling.SetMarkerWeights
import org.opensim.modeling.MarkerWeight
import org.opensim.modeling.MarkersReference
timeSeriesTable = TimeSeriesTableVec3(fileName);
strings = {};
columnNames = timeSeriesTable.getColumnLabels();
for i=0:columnNames.size()-1
    strings{end+1} = columnNames.get(i);
end
markerNames = string(strings);
markerWeightSet = SetMarkerWeights();
for i=1:length(markerNames)
    markerWeightSet.cloneAndAppend(MarkerWeight(markerNames(i), 1.0));
end
try
    markersReference = MarkersReference(fileName, markerWeightSet);
catch
    markersReference = MarkersReference(fileName);
    markersReference.setMarkerWeightSet(markerWeightSet)
end
timeSeriesTable = libpointer;
end

