% This function is part of the NMSM Pipeline, see file for full license.
%
% This function adds a "shadow foot" for each contact surface to the
% model. A shadow foot is a copy of the hindfoot and toes bodies of the
% contact surface. The shadow hindfoot is attached to ground with a six
% degree of freedom joint using the Ground Contact Personalization
% rotation sequence, and the shadow toes are attached to the shadow
% hindfoot with a copy of the model's toe joint. The shadow feet move
% independently of the rest of the model, and are kept in the same pose as
% the model's feet with the shadow_foot_pose path constraint.
%
% The new model is printed next to the original model with the suffix
% "_shadowFeet". New bodies, joints, and coordinates are appended to the
% end of their sets, so existing body indices are unchanged.
%
% (string, cell array of struct) -> (string, cell array of struct)
% Adds shadow feet to the model and returns the new model file name

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function [shadowModelFileName, contactSurfaces] = ...
    addShadowFeetToModel(modelFileName, contactSurfaces)
import org.opensim.modeling.*
model = Model(modelFileName);
model.finalizeConnections();
for i = 1 : length(contactSurfaces)
    surface = contactSurfaces{i};
    toesJointName = findToesJointName(model, surface.hindfootBodyName);
    [hindfootName, toesName] = getJointBodyNames(model, toesJointName);
    toesJoint = model.getJointSet().get(toesJointName);
    assert(toesJoint.numCoordinates() == 1, "Shadow feet require a " + ...
        "toe joint with exactly one coordinate: " + toesJointName);
    toesCoordinateName = string(toesJoint.get_coordinates(0).getName());

    shadowHindfootName = string(hindfootName) + "_shadow";
    shadowToesName = string(toesName) + "_shadow";
    shadowToesCoordinateName = toesCoordinateName + "_shadow";
    groundCoordinateNames = shadowHindfootName + ["_rotation1", ...
        "_rotation2", "_rotation3", "_translation1", ...
        "_translation2", "_translation3"];
    verifyNamesAreUnused(model, [shadowHindfootName, shadowToesName], ...
        [shadowToesCoordinateName, groundCoordinateNames]);

    addShadowBody(model, hindfootName, shadowHindfootName);
    addShadowBody(model, toesName, shadowToesName);
    groundJoint = makeHindfootGroundJoint(model, shadowHindfootName, ...
        surface.isLeftFoot, "ground_" + shadowHindfootName, ...
        groundCoordinateNames, true);
    model.addJoint(groundJoint);
    addShadowToesJoint(model, toesJointName, ...
        containers.Map({hindfootName, toesName}, ...
        {char(shadowHindfootName), char(shadowToesName)}), ...
        toesCoordinateName, shadowToesCoordinateName);
    model.finalizeConnections();
    widenGroundJointRanges(model, groundCoordinateNames);

    contactSurfaces{i}.toesCoordinateName = toesCoordinateName;
    contactSurfaces{i}.shadowHindfootBodyName = shadowHindfootName;
    contactSurfaces{i}.shadowToesBodyName = shadowToesName;
    % Same order as Ground Contact Personalization foot kinematics:
    % toe angle, three rotations, three translations
    contactSurfaces{i}.shadowCoordinateNames = ...
        [shadowToesCoordinateName, groundCoordinateNames];
end
model.initSystem();
% A char file name, as the MEX functions that load the model require
shadowModelFileName = [strrep(char(modelFileName), '.osim', ''), ...
    '_shadowFeet.osim'];
model.print(shadowModelFileName);
end

function toesJointName = findToesJointName(model, hindfootBodyName)
joints = getBodyJointNames(model, hindfootBodyName);
for i = 1 : length(joints)
    parent = getJointBodyNames(model, joints(i));
    if strcmp(parent, hindfootBodyName)
        toesJointName = joints(i);
        return
    end
end
throw(MException('', "Shadow feet could not find a toe joint " + ...
    "whose parent is " + hindfootBodyName))
end

function verifyNamesAreUnused(model, bodyNames, coordinateNames)
for i = 1 : length(bodyNames)
    assert(~model.getBodySet().contains(char(bodyNames(i))), "Shadow feet " + ...
        "cannot be added because the model already has a body named " + ...
        bodyNames(i))
end
for i = 1 : length(coordinateNames)
    assert(~model.getCoordinateSet().contains(char(coordinateNames(i))), ...
        "Shadow feet cannot be added because the model already has " + ...
        "a coordinate named " + coordinateNames(i))
end
end

% The shadow feet only exist to evaluate the ground contact springs, so
% their mass does not matter much. A 1 kg mass keeps the mass matrix well
% conditioned.
function addShadowBody(model, bodyName, shadowBodyName)
body = model.getBodySet().get(bodyName).clone();
body.setName(shadowBodyName);
body.setMass(1);
model.addBody(body);
end

function widenGroundJointRanges(model, groundCoordinateNames)
for i = 0 : 5
    coordinate = model.updCoordinateSet().get( ...
        char(groundCoordinateNames(i + 1)));
    if i < 3
        coordinate.setRangeMin(-4 * pi);
        coordinate.setRangeMax(4 * pi);
    else
        coordinate.setRangeMin(-100);
        coordinate.setRangeMax(100);
    end
    coordinate.setDefaultClamped(false);
end
end

% Copies the toe joint and repoints it to the shadow bodies. The offset
% frames of the joint (and the joint itself, if it has no offset frames)
% connect to bodies by path, so any path ending in a mapped body name is
% replaced with the shadow body name.
function addShadowToesJoint(model, toesJointName, bodyNameMap, ...
    toesCoordinateName, shadowToesCoordinateName)
import org.opensim.modeling.*
joint = model.getJointSet().get(toesJointName).clone();
joint.setName(string(toesJointName) + "_shadow");
for i = 0 : joint.getPropertyByName("frames").size() - 1
    repointSocket(joint.upd_frames(i).updSocket("parent"), bodyNameMap);
end
repointSocket(joint.updSocket("parent_frame"), bodyNameMap);
repointSocket(joint.updSocket("child_frame"), bodyNameMap);

joint.upd_coordinates(0).setName(shadowToesCoordinateName);
customJoint = CustomJoint.safeDownCast(joint);
if ~isempty(customJoint)
    transform = customJoint.upd_SpatialTransform();
    for i = 0 : 5
        axis = transform.updTransformAxis(i);
        names = axis.getCoordinateNamesInArray();
        changed = false;
        for j = 0 : names.getSize() - 1
            if strcmp(char(names.get(j)), toesCoordinateName)
                names.set(j, shadowToesCoordinateName);
                changed = true;
            end
        end
        if changed
            axis.setCoordinateNames(names);
        end
    end
end
model.addJoint(joint);
end

function repointSocket(socket, bodyNameMap)
path = char(socket.getConnecteePath());
parts = split(string(path), "/");
if ~isempty(parts) && isKey(bodyNameMap, char(parts(end)))
    parts(end) = bodyNameMap(char(parts(end)));
    socket.setConnecteePath(char(join(parts, "/")));
end
end
