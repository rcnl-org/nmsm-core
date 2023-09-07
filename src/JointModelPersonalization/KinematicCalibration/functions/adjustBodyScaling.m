% This function is part of the NMSM Pipeline, see file for full license.
%
% This function scales the body then moves the markers back to their
% original location. This is useful for scaling the body without moving
% the markers.
%
% (Model, string, number) -> ()
% Adjust the scaling of the body without moving the attached markers

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

function adjustBodyScaling(model, bodyName, value, anatomicalMarkers)

if ~anatomicalMarkers
    markers = getMarkersFromBody(model, bodyName);
    markerLocations = {};
    for i = 1:length(markers)
        markerLocations{i} = org.opensim.modeling.Vec3( ...
            model.getMarkerSet().get(markers{i}).get_location());
    end
end

state = initializeState(model);

scaleSet = org.opensim.modeling.ScaleSet();
scale = org.opensim.modeling.Scale();
scale.setSegmentName(bodyName);
scale.setScaleFactors(org.opensim.modeling.Vec3(value / ...
    getScalingParameterValue(model, bodyName)));
scale.setApply(true);
scaleSet.cloneAndAppend(scale);
model.scale(state, scaleSet, true, -1.0);

if ~anatomicalMarkers
    for i = 1:length(markers)
        model.getMarkerSet().get(markers{i}).set_location(markerLocations{i});
    end
end
end

