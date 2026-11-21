% This function is part of the NMSM Pipeline, see file for full license.
%
% This function makes a six degree of freedom CustomJoint between ground
% and the given hindfoot body. The rotation sequence is Y-X-Z for a right
% foot and (-Y)-(-X)-Z for a left foot, followed by X, Y, and Z
% translations. This is the sequence used by Ground Contact
% Personalization foot models and by Treatment Optimization shadow feet.
%
% When useOffsetFrames is true, the joint is built with zero offset frames
% on the parent and child so that joint utilities which read the parent
% and child frames' sockets (e.g. getJointBodyNames) work on the joint.
%
% (Model, string, logical, string, string array, logical) -> (CustomJoint)
% Makes a 6 DOF ground to hindfoot CustomJoint

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Robert Salati                             %
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

function groundJoint = makeHindfootGroundJoint(model, hindfootBody, ...
    isLeftFoot, jointName, coordinateNames, useOffsetFrames)
import org.opensim.modeling.*
if nargin < 4
    jointName = "ground_hindfoot";
end
if nargin < 5
    coordinateNames = ["Rotation1", "Rotation2", "Rotation3", ...
        "Translation1", "Translation2", "Translation3"];
end
if nargin < 6
    useOffsetFrames = false;
end
if isLeftFoot
    axes = {[0, -1, 0], [-1, 0, 0], [0, 0, 1], ...
        [1, 0, 0], [0, 1, 0], [0, 0, 1]};
else
    axes = {[0, 1, 0], [1, 0, 0], [0, 0, 1], ...
        [1, 0, 0], [0, 1, 0], [0, 0, 1]};
end
transform = SpatialTransform();
for i = 1 : 6
    nameArrayStr = ArrayStr();
    nameArrayStr.append(coordinateNames(i));
    axis = TransformAxis(nameArrayStr, Vec3(axes{i}(1), axes{i}(2), ...
        axes{i}(3)));
    axis.set_function(LinearFunction(1, 0));
    switch i
        case 1
            transform.set_rotation1(axis);
        case 2
            transform.set_rotation2(axis);
        case 3
            transform.set_rotation3(axis);
        case 4
            transform.set_translation1(axis);
        case 5
            transform.set_translation2(axis);
        case 6
            transform.set_translation3(axis);
    end
end

if useOffsetFrames
    groundJoint = CustomJoint(jointName, model.getGround(), Vec3(0), ...
        Vec3(0), model.getBodySet().get(hindfootBody), Vec3(0), Vec3(0), ...
        transform);
else
    groundJoint = CustomJoint(jointName, model.getGround(), ...
        model.getBodySet().get(hindfootBody), transform);
end
end
