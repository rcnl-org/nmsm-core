% This function is part of the NMSM Pipeline, see file for full license.
%
% This function gets the names of markers attached to a given body.
%
% (Model, string) -> (1D Array of strings)
% Returns the names of markers attached to the body

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

function markerNames = getMarkersFromBody(model, bodyName)
markerNames = {};
for j=0:model.getMarkerSet().getSize()-1
    markerName = model.getMarkerSet().get(j).getName().toCharArray';
    markerParentName = getMarkerBodyName(model, markerName);
    if(strcmp(markerParentName, bodyName))
        if(~markerIncluded(markerNames, markerName))
            markerNames{length(markerNames)+1} = markerName;
        end
    end
end
end

