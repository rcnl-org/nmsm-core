% This function is part of the NMSM Pipeline, see file for full license.
%
% This function removes markers from the model that are not in the list of
% kept markers.
%
% (model, array of string) -> None
% remove markers not in the list of kept markers

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

function removeNonUsedMarkers(model, keptMarkerNames)
toBeRemoved = [];
for i=0:model.getMarkerSet().getSize()-1
    markerName = model.getMarkerSet().get(i).getName();
    if(~markerIncluded(keptMarkerNames, markerName))
        toBeRemoved(length(toBeRemoved) + 1) = i;
    end
end
markerSet = model.updMarkerSet();
for i=1:length(toBeRemoved)
    markerSet.remove(toBeRemoved(length(toBeRemoved)-i+1));
end
end
