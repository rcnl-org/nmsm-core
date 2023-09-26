% This function is part of the NMSM Pipeline, see file for full license.
%
% If contact surfaces are present, point and torque actuators are added to
% the model. The actuators are only added to the bodies with contact
% surfaces.
%
% (struct, Model) -> (Model)
% Adds point and torque actuators to model

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function model = addContactSurfaceActuators(inputs, model)
import org.opensim.modeling.Vec3
for i = 1:length(inputs.contactSurfaces)
addPointActuator(model, string(inputs.contactSurfaces{i}.parentBodyName), Vec3(1, 0, 0));
addPointActuator(model, string(inputs.contactSurfaces{i}.parentBodyName), Vec3(0, 1, 0));
addPointActuator(model, string(inputs.contactSurfaces{i}.parentBodyName), Vec3(0, 0, 1));
addPointActuator(model, string(inputs.contactSurfaces{i}.childBodyName), Vec3(1, 0, 0));
addPointActuator(model, string(inputs.contactSurfaces{i}.childBodyName), Vec3(0, 1, 0));
addPointActuator(model, string(inputs.contactSurfaces{i}.childBodyName), Vec3(0, 0, 1));
addTorqueActuator(model, string(inputs.contactSurfaces{i}.parentBodyName), Vec3(1, 0, 0));
addTorqueActuator(model, string(inputs.contactSurfaces{i}.parentBodyName), Vec3(0, 1, 0));
addTorqueActuator(model, string(inputs.contactSurfaces{i}.parentBodyName), Vec3(0, 0, 1));
addTorqueActuator(model, string(inputs.contactSurfaces{i}.childBodyName), Vec3(1, 0, 0));
addTorqueActuator(model, string(inputs.contactSurfaces{i}.childBodyName), Vec3(0, 1, 0));
addTorqueActuator(model, string(inputs.contactSurfaces{i}.childBodyName), Vec3(0, 0, 1));
end
end
function addPointActuator(model, bodyName, direction)
import org.opensim.modeling.*
pointActuator = PointActuator();
pointActuator.setMaxControl(Inf);
pointActuator.setMinControl(-Inf);
pointActuator.set_body(bodyName);
pointActuator.set_point(Vec3(0, 0, 0));
pointActuator.set_point_is_global(0);
pointActuator.set_direction(direction);
pointActuator.set_force_is_global(1);
pointActuator.set_optimal_force(1);
model.addForce(pointActuator);
end
function addTorqueActuator(model, bodyName, direction)
import org.opensim.modeling.*
torqueActuator = TorqueActuator();
torqueActuator.setMaxControl(Inf);
torqueActuator.setMinControl(-Inf);
torqueActuator.set_bodyA(bodyName);
torqueActuator.set_bodyB("ground");
torqueActuator.set_torque_is_global(1);
torqueActuator.set_optimal_force(1);
torqueActuator.set_axis(direction);
model.addForce(torqueActuator);
end