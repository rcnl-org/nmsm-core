% This function is part of the NMSM Pipeline, see file for full license.
%
% This function converts hindfoot rotation matrices (body to ground, i.e.
% the columns are the body axes expressed in ground) into the rotation
% angles of the ground to hindfoot joint made by makeHindfootGroundJoint.
% The sequence is Y-X-Z for a right foot and (-Y)-(-X)-Z for a left foot.
%
% R is a 3 x 3 x numFrames array. angles is numFrames x 3, with columns
% matching the joint's rotation1, rotation2, and rotation3 coordinates.
%
% (3x3xN double, logical) -> (Nx3 double)
% Calculates the hindfoot ground joint rotation angles

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

function angles = calcHindfootJointAngles(R, isLeftFoot)
R13 = squeeze(R(1, 3, :));
R33 = squeeze(R(3, 3, :));
R23 = squeeze(R(2, 3, :));
R21 = squeeze(R(2, 1, :));
R22 = squeeze(R(2, 2, :));
if isLeftFoot
    q1 = atan2(-R13, R33);
    q2 = atan2(R23, sqrt(R13 .^ 2 + R33 .^ 2));
else
    q1 = atan2(R13, R33);
    q2 = atan2(-R23, sqrt(R13 .^ 2 + R33 .^ 2));
end
q3 = atan2(R21, R22);
angles = [q1(:), q2(:), q3(:)];
end
