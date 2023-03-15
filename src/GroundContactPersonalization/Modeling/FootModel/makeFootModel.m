% This function is part of the NMSM Pipeline, see file for full license.
%
% This function makes a new model with the parent and child bodies of the
% given toeJointName. For use in tracking joint kinematics in the GCP
% model.
%
% (Model, string) -> (Model)
% Makes a new model with just the hindfoot and toe bodies

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

function footModel = makeFootModel(model, toeJointName, isLeftFoot)
import org.opensim.modeling.*
footModel = Model();
[hindfootBody, toesBody] = getJointBodyNames(model, toeJointName);
footModel.addBody(model.getBodySet().get(hindfootBody).clone());
footModel.addBody(model.getBodySet().get(toesBody).clone());
footModel.addJoint(model.getJointSet().get(toeJointName).clone());
markers = getMarkersFromJoint(model, toeJointName);
for i=1:length(markers)
    footModel.addMarker(model.getMarkerSet().get(markers{i}).clone());
end

transform = SpatialTransform();
if isLeftFoot
    axis = TransformAxis(transform.get_rotation1().getCoordinateNamesInArray(), Vec3(0, -1, 0));
%     axis.setAxis(Vec3(0, -1, 0));
    transform.set_rotation1(axis);
    axis = TransformAxis(transform.get_rotation1().getCoordinateNamesInArray(), Vec3(-1, 0, 0));
%     axis.setAxis(Vec3(-1, 0, 0));
    transform.set_rotation2(axis);
else
    axis = TransformAxis(transform.get_rotation1().getCoordinateNamesInArray(), Vec3(0, 1, 0));
%     axis.setAxis(Vec3(0, 1, 0));
    axis.setCoordinateNames(transform.get_rotation1().getCoordinateNamesInArray());
    transform.set_rotation1(axis);
    axis = TransformAxis(transform.get_rotation1().getCoordinateNamesInArray(), Vec3(1, 0, 0));
%     axis.setAxis(Vec3(1, 0, 0));
    transform.set_rotation2(axis);
end
groundJoint = CustomJoint("ground_hindfoot", footModel.getGround(), ...
    footModel.getBodySet().get(hindfootBody), transform);
footModel.addJoint(groundJoint);

footModel.finalizeConnections()
% footModel = setDefaultPose(footModel, model, hindfootBody);
end

% Updates the default pose of a footModel to match the default of the model
function footModel = setDefaultPose(footModel, model, hindfootBody)
    [model, state] = Model(model);
    footPosition = model.getBodySet().get(hindfootBody) ...
        .getPositionInGround(state);
    footModel.getCoordinateSet().get(5) ...
        .set_default_value(footPosition.get(1))
end
