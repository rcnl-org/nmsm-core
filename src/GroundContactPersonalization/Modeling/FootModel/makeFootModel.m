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

function footModel = makeFootModel(model, toeJointName)
import org.opensim.modeling.Model
footModel = Model();
[hindfootBody, toesBody] = getJointBodyNames(model, toeJointName);
footModel.upd_BodySet().adoptAndAppend(model.getBodySet().get( ...
    hindfootBody));
footModel.upd_BodySet().adoptAndAppend(model.getBodySet().get( ...
    toesBody));
footModel.upd_JointSet().adoptAndAppend(model.getJointSet().get( ...
    toeJointName));
markers = getMarkersFromJoint(model, toeJointName);
for i=1:length(markers)
    footModel.upd_MarkerSet().adoptAndAppend( ...
        model.getMarkerSet().get(markers{i}));
end
footModel.finalizeConnections()
footModel = setDefaultPose(footModel, model, hindfootBody, toesBody);
end

% a function that updates the default pose of a footModel to match the default pose of the model
function footModel = setDefaultPose(footModel, model, hindfootBody, toesBody)
    [model, state] = Model(model);
    footPosition = model.getBodySet().get(hindfootBody).getPositionInGround(state);
%     footRotation = model.getBodySet().get(hindfootBody).getRotationInGround(state).convertRotationToBodyFixedXYZ()
    
%     for i = 0:2
%     footModel.getCoordinateSet().get(i+1).set_default_value(footRotation.get(i))
%     end
%     for i = 0:2
        footModel.getCoordinateSet().get(5).set_default_value(footPosition.get(1))
%     end
%     toeCoordinate = model.getCoordinateSet().get(getCoordinatesFromBodies(model, toesBody));
%     footModel.getCoordinateSet().get(0).set_default_value(toeCoordinate.getValue(state))
    footModel = Model(footModel);
end
