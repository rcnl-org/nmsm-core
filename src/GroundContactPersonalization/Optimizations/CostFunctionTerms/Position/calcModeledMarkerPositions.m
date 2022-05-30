% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (Array of double, 2D Matrix of double, 2D Matrix of double, ...
% Array of double) -> (2D Matrix of double)
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

function markerPositions = calcModeledMarkerPositions(jointRotations, ...
    jointLocations, markerLocations, jointCoordinates)

p1                              =  jointRotations(1);
p2                              =  jointRotations(2);
rx1                             =  jointLocations(1, 1);
rx3                             =  jointLocations(3, 1);
ry1                             =  jointLocations(1, 2); 
ry3                             =  jointLocations(3, 2);
rz1                             =  jointLocations(1, 3);
rz3                             =  jointLocations(3, 3);
sx1                             =  markerLocations(1, 1);
sx2                             =  markerLocations(2, 2);
sx3                             =  markerLocations(3, 3);
sx4                             =  markerLocations(4, 1);
sy1                             =  markerLocations(1, 2);
sy2                             =  markerLocations(2, 3);
sy3                             =  markerLocations(3, 1);
sy4                             =  markerLocations(4, 2);
sz1                             =  markerLocations(1, 3);
sz2                             =  markerLocations(2, 1);
sz3                             =  markerLocations(3, 2);
sz4                             =  markerLocations(4, 3);
q1                              =  jointCoordinates(1);
q2                              =  jointCoordinates(2);
q3                              =  jointCoordinates(3);
q4                              =  jointCoordinates(4);
q5                              =  jointCoordinates(5);
q6                              =  jointCoordinates(6);
q7                              =  jointCoordinates(7);

z = zeros(59,1);
z(1) = cos(q4);
z(2) = sin(q4);
z(3) = cos(q5);
z(4) = sin(q5);
z(5) = cos(q6);
z(6) = sin(q6);
z(7) = z(4)*z(6);
z(8) = z(4)*z(5);
z(9) = z(3)*z(6);
z(10) = z(3)*z(5);
z(11) = z(1)*z(5) - z(2)*z(7);
z(12) = z(2)*z(3);
z(13) = z(1)*z(6) + z(2)*z(8);
z(14) = z(1)*z(7) + z(2)*z(5);
z(15) = z(1)*z(3);
z(16) = z(2)*z(6) - z(1)*z(8);
z(17) = cos(p1);
z(18) = sin(p1);
z(19) = cos(p2);
z(20) = sin(p2);
z(21) = z(18)*z(20);
z(22) = z(18)*z(19);
z(23) = z(17)*z(20);
z(24) = z(17)*z(19);
z(25) = cos(q7);
z(26) = sin(q7);
z(27) = z(19)*z(25);
z(28) = z(21)*z(25) - z(17)*z(26);
z(29) = -z(18)*z(26) - z(23)*z(25);
z(30) = z(19)*z(26);
z(31) = z(17)*z(25) + z(21)*z(26);
z(32) = z(18)*z(25) - z(23)*z(26);
z(33) = z(20)^2;
z(34) = z(33) + z(19)*z(27);
z(35) = z(20)*z(22);
z(36) = z(19)*z(28) - z(35);
z(37) = z(20)*z(24);
z(38) = z(37) + z(19)*z(29);
z(39) = z(17)*z(30) + z(21)*z(27) - z(35);
z(40) = z(22)^2;
z(41) = z(40) + z(17)*z(31) + z(21)*z(28);
z(42) = z(22)*z(24);
z(43) = z(17)*z(32) + z(21)*z(29) - z(42);
z(44) = z(37) + z(18)*z(30) - z(23)*z(27);
z(45) = z(18)*z(31) - z(42) - z(23)*z(28);
z(46) = z(24)^2;
z(47) = z(46) + z(18)*z(32) - z(23)*z(29);
z(48) = z(11)*z(34) + z(13)*z(44) - z(12)*z(39);
z(49) = z(11)*z(36) + z(13)*z(45) - z(12)*z(41);
z(50) = z(11)*z(38) + z(13)*z(47) - z(12)*z(43);
z(51) = z(14)*z(34) + z(15)*z(39) + z(16)*z(44);
z(52) = z(14)*z(36) + z(15)*z(41) + z(16)*z(45);
z(53) = z(14)*z(38) + z(15)*z(43) + z(16)*z(47);
z(54) = z(4)*z(39) + z(10)*z(44) - z(9)*z(34);
z(55) = z(4)*z(41) + z(10)*z(45) - z(9)*z(36);
z(56) = z(4)*z(43) + z(10)*z(47) - z(9)*z(38);
z(57) = sx4 - rx3;
z(58) = sy4 - ry3;
z(59) = sz4 - rz3;

markerPositions(1) = q1 + sx1*z(11) + sz1*z(13) - sy1*z(12);
markerPositions(2) = q2 + sx1*z(14) + sy1*z(15) + sz1*z(16);
markerPositions(3) = q3 + sy1*z(4) + sz1*z(10) - sx1*z(9);
markerPositions(4) = q1 + sx2*z(11) + sz2*z(13) - sy2*z(12);
markerPositions(5) = q2 + sx2*z(14) + sy2*z(15) + sz2*z(16);
markerPositions(6) = q3 + sy2*z(4) + sz2*z(10) - sx2*z(9);
markerPositions(7) = q1 + sx3*z(11) + sz3*z(13) - sy3*z(12);
markerPositions(8) = q2 + sx3*z(14) + sy3*z(15) + sz3*z(16);
markerPositions(9) = q3 + sy3*z(4) + sz3*z(10) - sx3*z(9);
markerPositions(10) = q1 + rx1*z(11) + rz1*z(13) + z(57)*z(48) + z(58)*z(49) + z(59)*z(50) - ry1*z(12);
markerPositions(11) = q2 + rx1*z(14) + ry1*z(15) + rz1*z(16) + z(57)*z(51) + z(58)*z(52) + z(59)*z(53);
markerPositions(12) = q3 + ry1*z(4) + rz1*z(10) + z(57)*z(54) + z(58)*z(55) + z(59)*z(56) - rx1*z(9);

end





