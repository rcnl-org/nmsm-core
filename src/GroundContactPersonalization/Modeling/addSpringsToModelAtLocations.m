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
heelVec3 = model.getMarkerSet().get(heelMarkerName).getLocationInGround(state);
calcnToToes = model.getBodySet().get(toesBodyName).findTransformBetween( ...
    state, model.getBodySet().get(hindfootBodyName));

for i=1:length(insideToes)
    pointX = insideToes(i, 2) * normalizedFootHeight;
    pointX = pointX - calcnToToes.T.get(0);
    pointX = pointX - (calcnVec3.get(0) - heelVec3.get(0));
    if(isLeftFoot)
        pointY = 1 - insideToes(i, 1);
    end
    pointY = pointY * normalizedFootWidth;
    pointY = pointY - normalizedMarkerPositions.heel(2) * normalizedFootWidth;
    addSpringToModel(model, [pointX, pointY], toesBodyName, toesBodyName + "_marker_" + num2str(i))
end

for i=1:length(insideHindfoot)
    pointX = insideHindfoot(i, 2) * normalizedFootHeight;
    pointX = pointX - (calcnVec3.get(0) - heelVec3.get(0));
    if(isLeftFoot)
        pointY = 1 - insideHindfoot(i, 1);
    end
    pointY = pointY * normalizedFootWidth;
    pointY = pointY - normalizedMarkerPositions.heel(2) * normalizedFootWidth;
    addSpringToModel(model, [pointX, pointY], hindfootBodyName, hindfootBodyName + "hindfoot_marker_" + num2str(i))
end
end

function addSpringToModel(model, point, body, name)
import org.opensim.modeling.Marker
import org.opensim.modeling.Vec3
marker = Marker();
marker.setName(name);
marker.setParentFrame(model.getBodySet().get(body));
marker.set_location(Vec3(point(1), 0, point(2)));
model.addMarker(marker);
end