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

function [body, joint, coordinate] = adjustBodyScaling(model, bodyName, value, anatomicalMarkers)
body = bodyName;
joint = "";
coordinate = 0;
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
scaleFactor = value / getScalingParameterValue(model, bodyName);
scale.setScaleFactors(org.opensim.modeling.Vec3(scaleFactor));
scale.setApply(true);
scaleSet.cloneAndAppend(scale);
model.scale(state, scaleSet, true, -1.0);

indicesForRemoval = [];
for i = 0 : model.getConstraintSet().getSize() - 1
    parentStr = strsplit(string(model.getConstraintSet().get(i).getPropertyByName("socket_body_1").toString()), "/");
    parentStr = parentStr(end);
    childStr = strsplit(string(model.getConstraintSet().get(i).getPropertyByName("socket_body_2").toString()), "/");
    childStr = childStr(end);
    if strcmp(parentStr(end), bodyName)
        scaledLocation1 = getScaledLocation(1, model.getConstraintSet().get(i).getPropertyByName("location_body_1").toString());
        scaledLocation2 = getScaledLocation(scaleFactor, model.getConstraintSet().get(i).getPropertyByName("location_body_2").toString());
        % model.getConstraintSet().remove(i);
        indicesForRemoval(end + 1) = i;
        model.addConstraint(org.opensim.modeling.PointConstraint(...
            model.getBodySet().get(parentStr), ...
            scaledLocation1, ...
            model.getBodySet().get(childStr), ...
            scaledLocation2 ...
            ));
    elseif strcmp(childStr(end), bodyName)
        scaledLocation1 = getScaledLocation(1, model.getConstraintSet().get(i).getPropertyByName("location_body_1").toString());
        scaledLocation2 = getScaledLocation(scaleFactor, model.getConstraintSet().get(i).getPropertyByName("location_body_2").toString());
        % model.getConstraintSet().remove(i);
        indicesForRemoval(end + 1) = i;
        model.addConstraint(org.opensim.modeling.PointConstraint(...
            model.getBodySet().get(parentStr), ...
            scaledLocation1, ...
            model.getBodySet().get(childStr), ...
            scaledLocation2 ...
            ));
    end
end
for i = 1:length(indicesForRemoval)
    model.getConstraintSet().remove(indicesForRemoval(i));
end

if ~anatomicalMarkers
    for i = 1:length(markers)
        model.getMarkerSet().get(markers{i}).set_location(markerLocations{i});
    end
end
end

function newLocation = getScaledLocation(scaleFactor, vec3String)
vec3String = replace(replace(string(vec3String), "(", ""), ")", "");
vec3String = str2double(strsplit(vec3String));
vec3String = vec3String * scaleFactor;
newLocation = org.opensim.modeling.Vec3(vec3String(1), vec3String(2), vec3String(3));
end