% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the time derivatives of the hindfoot ground
% joint rotation angles returned by calcHindfootJointAngles (Y-X-Z for a
% right foot and (-Y)-(-X)-Z for a left foot). It differentiates the same
% atan2 expressions, given the rotation matrices (body to ground) and
% their time derivatives.
%
% R and RDot are 3 x 3 x numFrames arrays. rates is numFrames x 3, with
% columns matching the joint's rotation1, rotation2, and rotation3
% coordinates.
%
% (3x3xN double, 3x3xN double, logical) -> (Nx3 double)
% Calculates the hindfoot ground joint rotation angle rates

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

function rates = calcHindfootJointAngleRates(R, RDot, isLeftFoot)
R13 = squeeze(R(1, 3, :));
R33 = squeeze(R(3, 3, :));
R23 = squeeze(R(2, 3, :));
R21 = squeeze(R(2, 1, :));
R22 = squeeze(R(2, 2, :));
R13Dot = squeeze(RDot(1, 3, :));
R33Dot = squeeze(RDot(3, 3, :));
R23Dot = squeeze(RDot(2, 3, :));
R21Dot = squeeze(RDot(2, 1, :));
R22Dot = squeeze(RDot(2, 2, :));
if isLeftFoot
    % q1 = atan2(-R13, R33), q2 = atan2(R23, s)
    R13 = -R13;
    R13Dot = -R13Dot;
else
    % q1 = atan2(R13, R33), q2 = atan2(-R23, s)
    R23 = -R23;
    R23Dot = -R23Dot;
end
s = sqrt(R13 .^ 2 + R33 .^ 2);
sDot = (R13 .* R13Dot + R33 .* R33Dot) ./ s;
q1Dot = atan2Rate(R13, R33, R13Dot, R33Dot);
q2Dot = atan2Rate(R23, s, R23Dot, sDot);
q3Dot = atan2Rate(R21, R22, R21Dot, R22Dot);
rates = [q1Dot(:), q2Dot(:), q3Dot(:)];
end

% d/dt atan2(y, x)
function rate = atan2Rate(y, x, yDot, xDot)
rate = (x .* yDot - y .* xDot) ./ (x .^ 2 + y .^ 2);
end
