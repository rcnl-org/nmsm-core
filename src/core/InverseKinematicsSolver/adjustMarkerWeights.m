% This function is part of the NMSM Pipeline, see file for full license.
%
% This function changes the marker weights of the SetMarkerWeights object
% based on the struct given as input. The struct format is:
% field name=name of marker, field value = new weight (number)
% No change is applied if the weight is not a number
%
% (SetMarkerWeights, struct) -> (SetMarkerWeights)
% Changes the weight of specified markers in the SetMarkerWeights

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire Hammond                                               %
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

function newMarkerWeightSet = adjustMarkerWeights(markerWeightSet, ...
    markersToAdjust)
import org.opensim.modeling.*
newMarkerWeightSet = SetMarkerWeights(markerWeightSet);
namesMarkersToAdjust = string(fieldnames(markersToAdjust));
for i=1:length(namesMarkersToAdjust)
    for j=0:newMarkerWeightSet.getSize()-1
        if(namesMarkersToAdjust(i) == ...
            char(newMarkerWeightSet.get(j).getName()))
            newWeight = markersToAdjust.(namesMarkersToAdjust(i));
            if isnumeric(newWeight)
                newMarkerWeightSet.get(j).setWeight(newWeight);
                break
            end
        end
    end
end
end

