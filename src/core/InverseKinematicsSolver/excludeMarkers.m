% This function is part of the NMSM Pipeline, see file for full license.
%
% This function removes the markers as outlined in the input array. The
% input array is a 1D array of string names of the markers to remove from
% the SetMarkerWeights.
%
% (SetMarkerWeights, Array of strings) -> (SetMarkerWeights)
% Returns a marker weight set with the named markers removed

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

function newMarkerWeightSet = excludeMarkers(markerWeightSet, ...
    excludedMarkers)
import org.opensim.modeling.*
newMarkerWeightSet = SetMarkerWeights(markerWeightSet);
for i=1:length(excludedMarkers)
    for j=0:newMarkerWeightSet.getSize()-1
        if(excludedMarkers(i) == char(newMarkerWeightSet.get(j).getName()))
            newMarkerWeightSet.remove(j);
            break
        end
    end
end
end