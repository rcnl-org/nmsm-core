% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function model = addSpringsToModelAtLocations(model, markerPositions, ...
    normalizedMarkerPositions, insideToes, insideHindfoot, ...
    hindfootBodyName, toesBodyName, heelMarkerName, isLeftFoot)
[model, state] = Model(model);
normalizedFootHeight = abs(markerPositions.toe(1) - ...
    markerPositions.heel(1));
normalizedFootWidth = abs(markerPositions.medial(2) - ...
    markerPositions.lateral(2));
calcnVec3 = model.getBodySet().get(hindfootBodyName).getPositionInGround(state);
toesVec3 = model.getBodySet().get(toesBodyName).getPositionInGround(state);
heelVec3 = model.getMarkerSet().get(heelMarkerName).getLocationInGround(state);
calcnToToes = model.getBodySet().get(toesBodyName).findTransformBetween( ...
    state, model.getBodySet().get(hindfootBodyName));

markerNumber = 1;
markerPrefix = "spring_marker_";

for i=1:length(insideToes)
    newPoint = calcMarkerPosition(insideToes(i, :), normalizedFootHeight, normalizedFootWidth, normalizedMarkerPositions, calcnVec3, heelVec3, isLeftFoot);
    newPoint(1) = newPoint(1) - toesVec3.get(0) + calcnVec3.get(0);
    newPoint(2) = newPoint(2) - toesVec3.get(2) + calcnVec3.get(2);
    height = - calcnVec3.get(1);
    addSpringToModel(model, height, newPoint, toesBodyName, markerPrefix + num2str(markerNumber));
    markerNumber = markerNumber + 1;
end
for i=1:length(insideHindfoot)
    newPoint = calcMarkerPosition(insideHindfoot(i, :), normalizedFootHeight, normalizedFootWidth, normalizedMarkerPositions, calcnVec3, heelVec3, isLeftFoot);
    addSpringToModel(model, -calcnVec3.get(1), newPoint, hindfootBodyName, markerPrefix + num2str(markerNumber));
    markerNumber = markerNumber + 1;
end
end

function newPoint = calcMarkerPosition(point, normalizedFootHeight, normalizedFootWidth, normalizedMarkerPositions, calcnVec3, heelVec3, isLeftFoot)
    pointX = point(2) * normalizedFootHeight;
    pointX = pointX - (calcnVec3.get(0) - heelVec3.get(0));
    if(isLeftFoot)
        pointY = 1 - point(1);
    else
        pointY = point(1);
    end
    pointY = pointY * normalizedFootWidth;
    pointY = pointY - normalizedMarkerPositions.heel(2) * normalizedFootWidth;
    newPoint = [pointX, pointY];
end

function addSpringToModel(model, height, point, body, name)
import org.opensim.modeling.Marker
import org.opensim.modeling.Vec3
marker = Marker();
marker.setName(name);
marker.setParentFrame(model.getBodySet().get(body));
% bodyHeight = model.getBodySet().get(body).getPositionInGround(state).get(2);
marker.set_location(Vec3(point(1), height, point(2)));
model.addMarker(marker);
end