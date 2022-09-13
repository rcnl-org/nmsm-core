function FootContactOut


ec1                             =  electricalCenter(1);
ec2                             =  electricalCenter(2);
ec3                             =  electricalCenter(3); 
Grav                            =  gravity;
IA1                             =  inertias(1);
IA2                             =  inertias(2);
IA3                             =  inertias(3);
IB1                             =  inertias(4);
IB2                             =  inertias(5);
IB3                             =  inertias(6);
mA                              =  masses(1);
mB                              =  masses(2); 
p1                              =  jointRotations(1);
p2                              =  jointRotations(2);
rx1                             =  jointLocations(1, 1);
rx2                             =  jointLocations(2, 1);
rx3                             =  jointLocations(3, 1);
ry1                             =  jointLocations(1, 2);
ry2                             =  jointLocations(2, 2);
ry3                             =  jointLocations(3, 2);
rz1                             =  jointLocations(1, 3);
rz2                             =  jointLocations(2, 3);
rz3                             =  jointLocations(3, 3);
sx1                             =  markerLocations(1, 1);
sx2                             =  markerLocations(2, 1);
sx3                             =  markerLocations(3, 1);
sx4                             =  markerLocations(4, 1);
sy1                             =  markerLocations(1, 2);
sy2                             =  markerLocations(2, 2);
sy3                             =  markerLocations(3, 2);
sy4                             =  markerLocations(4, 2);
sz1                             =  markerLocations(1, 3);
sz2                             =  markerLocations(2, 3);
sz3                             =  markerLocations(3, 3);
sz4                             =  markerLocations(4, 3);
tx1                             =  markerLocations(1, 1);
tx2                             =  markerLocations(2, 1);
tx3                             =  markerLocations(3, 1);
tx4                             =  markerLocations(4, 1);
ty1                             =  markerLocations(1, 2);
ty2                             =  markerLocations(2, 2);
ty3                             =  markerLocations(3, 2);
ty4                             =  markerLocations(4, 2);
tz1                             =  markerLocations(1, 3);
tz2                             =  markerLocations(2, 3);
tz3                             =  markerLocations(3, 3);
tz4                             =  markerLocations(4, 3);
ux1                             =  centerOfMasses(1, 1);
ux2                             =  centerOfMasses(2, 1);
uy1                             =  centerOfMasses(1, 2);
uy2                             =  centerOfMasses(2, 2);
uz1                             =  centerOfMasses(1, 3);
uz2                             =  centerOfMasses(2, 3);
vx1                             =  springLocation(1, 1);
vx2                             =  springLocation(2, 1);
vy1                             =  springLocation(1, 2);
vy2                             =  springLocation(2, 2);
vz1                             =  springLocation(1, 3);
vz2                             =  springLocation(2, 3);
FG1                             =  0.0;                    % UNITS               Constant
FG2                             =  0.0;                    % UNITS               Constant
FG3                             =  0.0;                    % UNITS               Constant
FSA1                            =  0.0;                    % UNITS               Constant
FSA2                            =  0.0;                    % UNITS               Constant
FSA3                            =  0.0;                    % UNITS               Constant
FSB1                            =  0.0;                    % UNITS               Constant
FSB2                            =  0.0;                    % UNITS               Constant
FSB3                            =  0.0;                    % UNITS               Constant
q1                              =  jointCoordinates(1);
q2                              =  jointCoordinates(2);
q3                              =  jointCoordinates(3);
q4                              =  jointCoordinates(4);
q5                              =  jointCoordinates(5);
q6                              =  jointCoordinates(6);
q7                              =  jointCoordinates(7);
TG1                             =  0.0;                    % UNITS               Constant
TG2                             =  0.0;                    % UNITS               Constant
TG3                             =  0.0;                    % UNITS               Constant
TSA1                            =  0.0;                    % UNITS               Constant
TSA2                            =  0.0;                    % UNITS               Constant
TSA3                            =  0.0;                    % UNITS               Constant
TSB1                            =  0.0;                    % UNITS               Constant
TSB2                            =  0.0;                    % UNITS               Constant
TSB3                            =  0.0;                    % UNITS               Constant
u1                              =  jointVelocities(1)
u2                              =  jointVelocities(2)
u3                              =  jointVelocities(3)
u4                              =  jointVelocities(4);
u5                              =  jointVelocities(5);
u6                              =  jointVelocities(6);
u7                              =  jointVelocities(7);
u1p                             =  jointAccelerations(1);
u2p                             =  jointAccelerations(2);
u3p                             =  jointAccelerations(3);
u4p                             =  jointAccelerations(4);
u5p                             =  jointAccelerations(5);
u6p                             =  jointAccelerations(6);
u7p                             =  jointAccelerations(7);
%-------------------------------+--------------------------+-------------------+-----------------

% Unit conversions
Pi       = 3.141592653589793;
DEGtoRAD = Pi/180.0;
RADtoDEG = 180.0/Pi;

% Reserve space and initialize matrices
z = zeros(352,1);

% Evaluate constants
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
z(57) = z(5)*z(34) + z(6)*z(44);
z(58) = z(5)*z(36) + z(6)*z(45);
z(59) = z(5)*z(38) + z(6)*z(47);
z(60) = z(5)*u5 - z(9)*u4;
z(61) = u6 + z(4)*u4;
z(62) = z(6)*u5 + z(10)*u4;
z(63) = z(3)*z(5)*u6 - z(4)*z(6)*u5;
z(64) = -z(6)*u5*u6 - u4*z(63);
z(65) = z(3)*u4*u5;
z(66) = -z(3)*z(6)*u6 - z(4)*z(5)*u5;
z(67) = z(5)*u5*u6 + u4*z(66);
z(68) = z(20)*u7 + z(39)*u6 + z(54)*u4 + z(57)*u5;
z(69) = z(41)*u6 + z(55)*u4 + z(58)*u5 - z(22)*u7;
z(70) = z(24)*u7 + z(43)*u6 + z(56)*u4 + z(59)*u5;
z(71) = z(19)*z(25)*u7;
z(72) = z(19)*z(26)*u7;
z(73) = z(17)*z(71) - z(21)*z(72);
z(74) = z(18)*z(71) + z(23)*z(72);
z(75) = z(3)*z(39)*u5 + z(4)*z(73) + z(10)*z(74) + z(44)*z(66) + z(19)*z(9)*z(72) - z(34)*z(63);
z(76) = z(5)*z(44)*u6 + z(6)*z(74) - z(6)*z(34)*u6 - z(19)*z(5)*z(72);
z(77) = u4*z(75) + u5*z(76) + u6*z(73);
z(78) = (z(17)*z(26)-z(21)*z(25))*u7;
z(79) = (z(17)*z(25)+z(21)*z(26))*u7;
z(80) = -z(17)*z(78) - z(21)*z(79);
z(81) = z(23)*z(79) - z(18)*z(78);
z(82) = z(3)*z(41)*u5 + z(4)*z(80) + z(10)*z(81) + z(45)*z(66) + z(19)*z(9)*z(79) - z(36)*z(63);
z(83) = z(5)*z(45)*u6 + z(6)*z(81) - z(6)*z(36)*u6 - z(19)*z(5)*z(79);
z(84) = u4*z(82) + u5*z(83) + u6*z(80);
z(85) = (z(18)*z(26)+z(23)*z(25))*u7;
z(86) = (z(18)*z(25)-z(23)*z(26))*u7;
z(87) = -z(17)*z(85) - z(21)*z(86);
z(88) = z(23)*z(86) - z(18)*z(85);
z(89) = z(3)*z(43)*u5 + z(4)*z(87) + z(10)*z(88) + z(47)*z(66) + z(19)*z(9)*z(86) - z(38)*z(63);
z(90) = z(5)*z(47)*u6 + z(6)*z(88) - z(6)*z(38)*u6 - z(19)*z(5)*z(86);
z(91) = u4*z(89) + u5*z(90) + u6*z(87);
z(92) = uy1*z(5);
z(93) = -ux1*z(4) - uy1*z(9);
z(94) = ux1*z(6) - uz1*z(5);
z(95) = ux1*z(10) + uz1*z(9);
z(96) = uz1*z(4) - uy1*z(10);
z(97) = uy1*z(6);
z(98) = ry1*z(5);
z(99) = -rx1*z(4) - ry1*z(9);
z(100) = rx1*z(6) - rz1*z(5);
z(101) = rx1*z(10) + rz1*z(9);
z(102) = rz1*z(4) - ry1*z(10);
z(103) = ry1*z(6);
z(104) = ry2*z(5);
z(105) = -rx2*z(4) - ry2*z(9);
z(106) = rx2*z(6) - rz2*z(5);
z(107) = rx2*z(10) + rz2*z(9);
z(108) = rz2*z(4) - ry2*z(10);
z(109) = ry2*z(6);
z(110) = ux2 - rx3;
z(111) = uy2 - ry3;
z(112) = uz2 - rz3;
z(113) = rz1*z(34) - rx1*z(44);
z(114) = z(34)*z(102) + z(39)*z(101) + z(44)*z(99);
z(115) = z(39)*z(100) + z(44)*z(98) - z(34)*z(103);
z(116) = rz1*z(36) - rx1*z(45);
z(117) = z(36)*z(102) + z(41)*z(101) + z(45)*z(99);
z(118) = z(41)*z(100) + z(45)*z(98) - z(36)*z(103);
z(119) = rz1*z(38) - rx1*z(47);
z(120) = z(38)*z(102) + z(43)*z(101) + z(47)*z(99);
z(121) = z(43)*z(100) + z(47)*z(98) - z(38)*z(103);
z(122) = z(20)*z(111) + z(22)*z(110);
z(123) = z(111)*z(39) - z(110)*z(41);
z(124) = z(111)*z(54) - z(110)*z(55);
z(125) = z(111)*z(57) - z(110)*z(58);
z(126) = z(24)*z(110) - z(20)*z(112);
z(127) = z(110)*z(43) - z(112)*z(39);
z(128) = z(110)*z(56) - z(112)*z(54);
z(129) = z(110)*z(59) - z(112)*z(57);
z(130) = -z(22)*z(112) - z(24)*z(111);
z(131) = z(112)*z(41) - z(111)*z(43);
z(132) = z(112)*z(55) - z(111)*z(56);
z(133) = z(112)*z(58) - z(111)*z(59);
z(134) = z(113) + z(131);
z(135) = z(114) + z(132);
z(136) = z(115) + z(133);
z(137) = z(116) + z(127);
z(138) = z(117) + z(128);
z(139) = z(118) + z(129);
z(140) = z(119) + z(123);
z(141) = z(120) + z(124);
z(142) = z(121) + z(125);
z(143) = -rx3*z(22) - ry3*z(20);
z(144) = rx3*z(41) - ry3*z(39);
z(145) = rx3*z(55) - ry3*z(54);
z(146) = rx3*z(58) - ry3*z(57);
z(147) = rz3*z(20) - rx3*z(24);
z(148) = rz3*z(39) - rx3*z(43);
z(149) = rz3*z(54) - rx3*z(56);
z(150) = rz3*z(57) - rx3*z(59);
z(151) = ry3*z(24) + rz3*z(22);
z(152) = ry3*z(43) - rz3*z(41);
z(153) = ry3*z(56) - rz3*z(55);
z(154) = ry3*z(59) - rz3*z(58);
z(155) = z(113) + z(152);
z(156) = z(114) + z(153);
z(157) = z(115) + z(154);
z(158) = z(116) + z(148);
z(159) = z(117) + z(149);
z(160) = z(118) + z(150);
z(161) = z(119) + z(144);
z(162) = z(120) + z(145);
z(163) = z(121) + z(146);
z(164) = uy1*z(64) - ux1*z(65);
z(165) = ux1*z(67) - uz1*z(64);
z(166) = uz1*z(65) - uy1*z(67);
z(167) = z(166) - (z(94)*u5+z(95)*u4)*z(62) - (ux1*u6-z(92)*u5-z(93)*u4)*z(61);
z(168) = z(165) + (uz1*u6+z(96)*u4-z(97)*u5)*z(62) + (ux1*u6-z(92)*u5-z(93)*u4)*z(60);
z(169) = z(164) + (z(94)*u5+z(95)*u4)*z(60) - (uz1*u6+z(96)*u4-z(97)*u5)*z(61);
z(170) = ry1*z(64) - rx1*z(65);
z(171) = rx1*z(67) - rz1*z(64);
z(172) = rz1*z(65) - ry1*z(67);
z(173) = z(172) - (z(100)*u5+z(101)*u4)*z(62) - (rx1*u6-z(98)*u5-z(99)*u4)*z(61);
z(174) = z(171) + (rz1*u6+z(102)*u4-z(103)*u5)*z(62) + (rx1*u6-z(98)*u5-z(99)*u4)*z(60);
z(175) = z(170) + (z(100)*u5+z(101)*u4)*z(60) - (rz1*u6+z(102)*u4-z(103)*u5)*z(61);
z(176) = z(34)*z(173) + z(39)*z(174) + z(44)*z(175);
z(177) = z(36)*z(173) + z(41)*z(174) + z(45)*z(175);
z(178) = z(38)*z(173) + z(43)*z(174) + z(47)*z(175);
z(179) = z(111)*z(77) - z(110)*z(84);
z(180) = z(110)*z(91) - z(112)*z(77);
z(181) = z(112)*z(84) - z(111)*z(91);
z(182) = z(176) + z(181) + (z(122)*u7+z(123)*u6+z(124)*u4+z(125)*u5)*z(69) - (z(126)*u7+z(127)*u6+z(128)*u4+z(129)*u5)*z(70);
z(183) = z(177) + z(180) + (z(130)*u7+z(131)*u6+z(132)*u4+z(133)*u5)*z(70) - (z(122)*u7+z(123)*u6+z(124)*u4+z(125)*u5)*z(68);
z(184) = z(178) + z(179) + (z(126)*u7+z(127)*u6+z(128)*u4+z(129)*u5)*z(68) - (z(130)*u7+z(131)*u6+z(132)*u4+z(133)*u5)*z(69);
z(185) = ec2 - q2;
z(186) = q3 - ec3;
z(187) = TSA1 + FSA3*(ec2-q2) - FSA2*(ec3-q3);
z(188) = ec3 - q3;
z(189) = q1 - ec1;
z(190) = TSA2 + FSA1*(ec3-q3) - FSA3*(ec1-q1);
z(191) = ec1 - q1;
z(192) = q2 - ec2;
z(193) = TSA3 + FSA2*(ec1-q1) - FSA1*(ec2-q2);
z(194) = TSB1 + FSB3*(ec2-q2) + rx3*FSB3*z(51) + ry1*FSB2*z(4) + ry3*FSB3*z(52) + rz1*FSB2*z(10) + rz3*FSB3*z(53) - FSB2*(ec3-q3) - rx1*FSB2*z(9) - rx1*FSB3*z(14) - rx3*FSB2*z(54) - ry1*FSB3*z(15) - ry3*FSB2*z(55) - rz1*FSB3*z(16) - rz3*FSB2*z(56);
z(195) = TSB2 + FSB1*(ec3-q3) + rx1*FSB1*z(9) + rx1*FSB3*z(11) + rx3*FSB1*z(54) + ry3*FSB1*z(55) + rz1*FSB3*z(13) + rz3*FSB1*z(56) - FSB3*(ec1-q1) - rx3*FSB3*z(48) - ry1*FSB1*z(4) - ry1*FSB3*z(12) - ry3*FSB3*z(49) - rz1*FSB1*z(10) - rz3*FSB3*z(50);
z(196) = TSB3 + FSB2*(ec1-q1) + rx1*FSB1*z(14) + rx3*FSB2*z(48) + ry1*FSB1*z(15) + ry1*FSB2*z(12) + ry3*FSB2*z(49) + rz1*FSB1*z(16) + rz3*FSB2*z(50) - FSB1*(ec2-q2) - rx1*FSB2*z(11) - rx3*FSB1*z(51) - ry3*FSB1*z(52) - rz1*FSB2*z(13) - rz3*FSB1*z(53);
z(197) = Grav*mA;
z(198) = Grav*mB;
z(199) = z(11)^2 + z(12)^2 + z(13)^2;
z(200) = z(11)*z(14) + z(13)*z(16) - z(12)*z(15);
z(201) = z(10)*z(13) - z(4)*z(12) - z(9)*z(11);
z(202) = FSA1 + FSB1*z(48)^2 + FSB1*z(49)^2 + FSB1*z(50)^2 + FSB2*z(48)*z(51) + FSB2*z(49)*z(52) + FSB2*z(50)*z(53) + FSB3*z(48)*z(54) + FSB3*z(49)*z(55) + FSB3*z(50)*z(56) + z(197)*(z(12)*z(15)-z(11)*z(14)-z(13)*z(16)) - z(198)*(z(48)*z(51)+z(49)*z(52)+z(50)*z(53));
z(203) = z(14)^2 + z(15)^2 + z(16)^2;
z(204) = z(4)*z(15) + z(10)*z(16) - z(9)*z(14);
z(205) = FSA2 + FSB1*z(48)*z(51) + FSB1*z(49)*z(52) + FSB1*z(50)*z(53) + FSB2*z(51)^2 + FSB2*z(52)^2 + FSB2*z(53)^2 + FSB3*z(51)*z(54) + FSB3*z(52)*z(55) + FSB3*z(53)*z(56) - z(197)*(z(14)^2+z(15)^2+z(16)^2) - z(198)*(z(51)^2+z(52)^2+z(53)^2);
z(206) = z(4)^2 + z(9)^2 + z(10)^2;
z(207) = FSA3 + FSB1*z(48)*z(54) + FSB1*z(49)*z(55) + FSB1*z(50)*z(56) + FSB2*z(51)*z(54) + FSB2*z(52)*z(55) + FSB2*z(53)*z(56) + FSB3*z(54)^2 + FSB3*z(55)^2 + FSB3*z(56)^2 + z(197)*(z(9)*z(14)-z(4)*z(15)-z(10)*z(16)) - z(198)*(z(51)*z(54)+z(52)*z(55)+z(53)*z(56));
z(208) = z(4)*z(15)*z(188) + z(10)*z(16)*z(188) + z(192)*z(4)^2 + z(192)*z(9)^2 + z(192)*z(10)^2 - z(9)*z(14)*z(188);
z(209) = z(4)*z(15)*z(189) + z(10)*z(13)*z(185) + z(10)*z(16)*z(189) - z(4)*z(12)*z(185) - z(9)*z(11)*z(185) - z(9)*z(14)*z(189);
z(210) = z(10)*z(13)*z(186) + z(191)*z(4)^2 + z(191)*z(9)^2 + z(191)*z(10)^2 - z(4)*z(12)*z(186) - z(9)*z(11)*z(186);
z(211) = z(20)*z(9) + z(20)*z(54) + z(22)*z(4) + z(24)*z(56) - z(22)*z(55) - z(24)*z(10);
z(212) = z(11)*z(108) + z(13)*z(105) - z(12)*z(107);
z(213) = z(14)*z(108) + z(15)*z(107) + z(16)*z(105);
z(214) = z(4)*z(107) + z(10)*z(105) - z(9)*z(108);
z(215) = FSB1*z(48)*z(156) + FSB1*z(49)*z(159) + FSB1*z(50)*z(162) + FSB2*z(51)*z(156) + FSB2*z(52)*z(159) + FSB2*z(53)*z(162) + FSB3*z(54)*z(156) + FSB3*z(55)*z(159) + FSB3*z(56)*z(162) + z(4)*z(15)*z(190) + z(10)*z(13)*z(187) + z(10)*z(16)*z(190) + z(48)*z(54)*z(194) + z(49)*z(55)*z(194) + z(50)*z(56)*z(194) + z(51)*z(54)*z(195) + z(52)*z(55)*z(195) + z(53)*z(56)*z(195) + z(193)*z(4)^2 + z(193)*z(9)^2 + z(193)*z(10)^2 + z(196)*z(54)^2 + z(196)*z(55)^2 + z(196)*z(56)^2 - z(4)*z(12)*z(187) - z(9)*z(11)*z(187) - z(9)*z(14)*z(190) - z(197)*(z(14)*z(96)+z(15)*z(95)+z(16)*z(93)) - z(198)*(z(51)*z(135)+z(52)*z(138)+z(53)*z(141));
z(216) = z(5)*z(11) + z(6)*z(13);
z(217) = z(5)*z(11)*z(186) + z(6)*z(10)*z(191) + z(6)*z(13)*z(186) - z(5)*z(9)*z(191);
z(218) = z(5)*z(11)*z(185) + z(5)*z(14)*z(189) + z(6)*z(13)*z(185) + z(6)*z(16)*z(189);
z(219) = z(5)*z(14) + z(6)*z(16);
z(220) = z(5)*z(14)*z(188) + z(6)*z(10)*z(192) + z(6)*z(16)*z(188) - z(5)*z(9)*z(192);
z(221) = z(6)*z(10) - z(5)*z(9);
z(222) = z(20)*z(57) + z(24)*z(59) - z(20)*z(5) - z(22)*z(58) - z(24)*z(6);
z(223) = z(13)*z(104) - z(11)*z(109) - z(12)*z(106);
z(224) = z(15)*z(106) + z(16)*z(104) - z(14)*z(109);
z(225) = z(4)*z(106) + z(9)*z(109) + z(10)*z(104);
z(226) = FSB1*z(48)*z(157) + FSB1*z(49)*z(160) + FSB1*z(50)*z(163) + FSB2*z(51)*z(157) + FSB2*z(52)*z(160) + FSB2*z(53)*z(163) + FSB3*z(54)*z(157) + FSB3*z(55)*z(160) + FSB3*z(56)*z(163) + z(5)*z(11)*z(187) + z(5)*z(14)*z(190) + z(6)*z(10)*z(193) + z(6)*z(13)*z(187) + z(6)*z(16)*z(190) + z(48)*z(57)*z(194) + z(49)*z(58)*z(194) + z(50)*z(59)*z(194) + z(51)*z(57)*z(195) + z(52)*z(58)*z(195) + z(53)*z(59)*z(195) + z(54)*z(57)*z(196) + z(55)*z(58)*z(196) + z(56)*z(59)*z(196) + z(197)*(z(14)*z(97)-z(15)*z(94)-z(16)*z(92)) - z(5)*z(9)*z(193) - z(198)*(z(51)*z(136)+z(52)*z(139)+z(53)*z(142));
z(227) = z(4)*z(192) + z(15)*z(188);
z(228) = z(4)*z(191) - z(12)*z(186);
z(229) = z(15)*z(189) - z(12)*z(185);
z(230) = z(22) + z(20)*z(39) + z(24)*z(43) - z(22)*z(41);
z(231) = rz2*z(11) - rx2*z(13);
z(232) = rz2*z(14) - rx2*z(16);
z(233) = -rx2*z(10) - rz2*z(9);
z(234) = z(4)*z(193) + z(15)*z(190) + FSB1*z(48)*z(155) + FSB1*z(49)*z(158) + FSB1*z(50)*z(161) + FSB2*z(51)*z(155) + FSB2*z(52)*z(158) + FSB2*z(53)*z(161) + FSB3*z(54)*z(155) + FSB3*z(55)*z(158) + FSB3*z(56)*z(161) + z(39)*z(48)*z(194) + z(39)*z(51)*z(195) + z(39)*z(54)*z(196) + z(41)*z(49)*z(194) + z(41)*z(52)*z(195) + z(41)*z(55)*z(196) + z(43)*z(50)*z(194) + z(43)*z(53)*z(195) + z(43)*z(56)*z(196) + z(197)*(ux1*z(16)-uz1*z(14)) - z(12)*z(187) - z(198)*(z(51)*z(134)+z(52)*z(137)+z(53)*z(140));
z(235) = z(20)^2 + z(22)^2 + z(24)^2;
z(236) = z(20)*z(48)*z(194) + z(20)*z(51)*z(195) + z(20)*z(54)*z(196) + z(24)*z(50)*z(194) + z(24)*z(53)*z(195) + z(24)*z(56)*z(196) + z(143)*FSB1*z(50) + z(143)*FSB2*z(53) + z(143)*FSB3*z(56) + z(147)*FSB1*z(49) + z(147)*FSB2*z(52) + z(147)*FSB3*z(55) + z(151)*FSB1*z(48) + z(151)*FSB2*z(51) + z(151)*FSB3*z(54) - z(22)*z(49)*z(194) - z(22)*z(52)*z(195) - z(22)*z(55)*z(196) - z(198)*(z(122)*z(53)+z(126)*z(52)+z(130)*z(51));
z(237) = IA1*z(60);
z(238) = IA2*z(61);
z(239) = IA3*z(62);
z(240) = IA1*z(5);
z(241) = IA1*z(9);
z(242) = IA1*z(64);
z(243) = IA2*z(4);
z(244) = IA2*z(65);
z(245) = IA3*z(6);
z(246) = IA3*z(10);
z(247) = IA3*z(67);
z(248) = z(60)*z(238) - z(61)*z(237);
z(249) = z(62)*z(237) - z(60)*z(239);
z(250) = z(61)*z(239) - z(62)*z(238);
z(251) = IB1*z(68);
z(252) = IB2*z(69);
z(253) = IB3*z(70);
z(254) = IB1*z(20);
z(255) = IB1*z(39);
z(256) = IB1*z(54);
z(257) = IB1*z(57);
z(258) = IB1*z(77);
z(259) = IB2*z(41);
z(260) = IB2*z(55);
z(261) = IB2*z(58);
z(262) = IB2*z(22);
z(263) = IB2*z(84);
z(264) = IB3*z(24);
z(265) = IB3*z(43);
z(266) = IB3*z(56);
z(267) = IB3*z(59);
z(268) = IB3*z(91);
z(269) = z(68)*z(252) - z(69)*z(251);
z(270) = z(70)*z(251) - z(68)*z(253);
z(271) = z(69)*z(253) - z(70)*z(252);
z(272) = mB*(z(48)*z(134)+z(49)*z(137)+z(50)*z(140)) - mA*(ux1*z(13)-uz1*z(11));
z(273) = mA*(z(11)^2+z(12)^2+z(13)^2) + mB*(z(48)^2+z(49)^2+z(50)^2);
z(274) = mB*(z(48)*z(51)+z(49)*z(52)+z(50)*z(53)) - mA*(z(12)*z(15)-z(11)*z(14)-z(13)*z(16));
z(275) = mB*(z(48)*z(135)+z(49)*z(138)+z(50)*z(141)) - mA*(z(12)*z(95)-z(11)*z(96)-z(13)*z(93));
z(276) = mB*(z(48)*z(54)+z(49)*z(55)+z(50)*z(56)) - mA*(z(4)*z(12)+z(9)*z(11)-z(10)*z(13));
z(277) = mB*(z(48)*z(136)+z(49)*z(139)+z(50)*z(142)) - mA*(z(11)*z(97)+z(12)*z(94)-z(13)*z(92));
z(278) = mB*(z(122)*z(50)+z(126)*z(49)+z(130)*z(48));
z(279) = mB*(z(48)*z(182)+z(49)*z(183)+z(50)*z(184)) - mA*(z(12)*z(168)-z(11)*z(167)-z(13)*z(169));
z(280) = mB*(z(51)*z(134)+z(52)*z(137)+z(53)*z(140)) - mA*(ux1*z(16)-uz1*z(14));
z(281) = mA*(z(14)^2+z(15)^2+z(16)^2) + mB*(z(51)^2+z(52)^2+z(53)^2);
z(282) = mA*(z(14)*z(96)+z(15)*z(95)+z(16)*z(93)) + mB*(z(51)*z(135)+z(52)*z(138)+z(53)*z(141));
z(283) = mB*(z(51)*z(54)+z(52)*z(55)+z(53)*z(56)) - mA*(z(9)*z(14)-z(4)*z(15)-z(10)*z(16));
z(284) = mB*(z(51)*z(136)+z(52)*z(139)+z(53)*z(142)) - mA*(z(14)*z(97)-z(15)*z(94)-z(16)*z(92));
z(285) = mB*(z(122)*z(53)+z(126)*z(52)+z(130)*z(51));
z(286) = mA*(z(14)*z(167)+z(15)*z(168)+z(16)*z(169)) + mB*(z(51)*z(182)+z(52)*z(183)+z(53)*z(184));
z(287) = mB*(z(54)*z(134)+z(55)*z(137)+z(56)*z(140)) - mA*(ux1*z(10)+uz1*z(9));
z(288) = mB*(z(54)*z(135)+z(55)*z(138)+z(56)*z(141)) - mA*(z(9)*z(96)-z(4)*z(95)-z(10)*z(93));
z(289) = mA*(z(4)^2+z(9)^2+z(10)^2) + mB*(z(54)^2+z(55)^2+z(56)^2);
z(290) = mA*(z(4)*z(94)+z(9)*z(97)+z(10)*z(92)) + mB*(z(54)*z(136)+z(55)*z(139)+z(56)*z(142));
z(291) = mB*(z(122)*z(56)+z(126)*z(55)+z(130)*z(54));
z(292) = mB*(z(54)*z(182)+z(55)*z(183)+z(56)*z(184)) - mA*(z(9)*z(167)-z(4)*z(168)-z(10)*z(169));
z(293) = IA2*z(4) + z(54)*z(255) + z(55)*z(259) + z(56)*z(265) + mB*(z(134)*z(135)+z(137)*z(138)+z(140)*z(141)) - mA*(ux1*z(93)-uz1*z(96));
z(294) = z(4)*z(243) + z(9)*z(241) + z(10)*z(246) + z(54)*z(256) + z(55)*z(260) + z(56)*z(266) + mA*(z(93)^2+z(95)^2+z(96)^2) + mB*(z(135)^2+z(138)^2+z(141)^2);
z(295) = z(10)*z(245) + z(54)*z(257) + z(55)*z(261) + z(56)*z(267) + mB*(z(135)*z(136)+z(138)*z(139)+z(141)*z(142)) + mA*(z(92)*z(93)+z(94)*z(95)-z(96)*z(97)) - z(9)*z(240);
z(296) = z(254)*z(54) + z(264)*z(56) + mB*(z(122)*z(141)+z(126)*z(138)+z(130)*z(135)) - z(262)*z(55);
z(297) = z(4)*z(244) + z(4)*z(249) + z(10)*z(247) + z(10)*z(248) + z(54)*z(258) + z(54)*z(271) + z(55)*z(263) + z(55)*z(270) + z(56)*z(268) + z(56)*z(269) + mA*(z(93)*z(169)+z(95)*z(168)+z(96)*z(167)) + mB*(z(135)*z(182)+z(138)*z(183)+z(141)*z(184)) - z(9)*z(242) - z(9)*z(250);
z(298) = z(5)*z(240) + z(6)*z(245) + z(57)*z(257) + z(58)*z(261) + z(59)*z(267) + mA*(z(92)^2+z(94)^2+z(97)^2) + mB*(z(136)^2+z(139)^2+z(142)^2);
z(299) = z(6)*z(246) + z(57)*z(256) + z(58)*z(260) + z(59)*z(266) + mB*(z(135)*z(136)+z(138)*z(139)+z(141)*z(142)) + mA*(z(92)*z(93)+z(94)*z(95)-z(96)*z(97)) - z(5)*z(241);
z(300) = z(254)*z(57) + z(264)*z(59) + mB*(z(122)*z(142)+z(126)*z(139)+z(130)*z(136)) - z(262)*z(58);
z(301) = z(57)*z(255) + z(58)*z(259) + z(59)*z(265) + mB*(z(134)*z(136)+z(137)*z(139)+z(140)*z(142)) - mA*(ux1*z(92)+uz1*z(97));
z(302) = z(5)*z(242) + z(5)*z(250) + z(6)*z(247) + z(6)*z(248) + z(57)*z(258) + z(57)*z(271) + z(58)*z(263) + z(58)*z(270) + z(59)*z(268) + z(59)*z(269) + mB*(z(136)*z(182)+z(139)*z(183)+z(142)*z(184)) + mA*(z(92)*z(169)+z(94)*z(168)-z(97)*z(167));
z(303) = IA2 + mA*(ux1^2+uz1^2);
z(304) = z(303) + z(39)*z(255) + z(41)*z(259) + z(43)*z(265) + mB*(z(134)^2+z(137)^2+z(140)^2);
z(305) = z(243) + z(39)*z(256) + z(41)*z(260) + z(43)*z(266) + mB*(z(134)*z(135)+z(137)*z(138)+z(140)*z(141)) - mA*(ux1*z(93)-uz1*z(96));
z(306) = z(254)*z(39) + z(264)*z(43) + mB*(z(122)*z(140)+z(126)*z(137)+z(130)*z(134)) - z(262)*z(41);
z(307) = z(39)*z(257) + z(41)*z(261) + z(43)*z(267) + mB*(z(134)*z(136)+z(137)*z(139)+z(140)*z(142)) - mA*(ux1*z(92)+uz1*z(97));
z(308) = z(244) + z(249) + z(39)*z(258) + z(39)*z(271) + z(41)*z(263) + z(41)*z(270) + z(43)*z(268) + z(43)*z(269) + mB*(z(134)*z(182)+z(137)*z(183)+z(140)*z(184)) - mA*(ux1*z(169)-uz1*z(167));
z(309) = z(20)*z(254) + z(22)*z(262) + z(24)*z(264) + mB*(z(122)^2+z(126)^2+z(130)^2);
z(310) = z(20)*z(255) + z(24)*z(265) + mB*(z(122)*z(140)+z(126)*z(137)+z(130)*z(134)) - z(22)*z(259);
z(311) = z(20)*z(256) + z(24)*z(266) + mB*(z(122)*z(141)+z(126)*z(138)+z(130)*z(135)) - z(22)*z(260);
z(312) = z(20)*z(257) + z(24)*z(267) + mB*(z(122)*z(142)+z(126)*z(139)+z(130)*z(136)) - z(22)*z(261);
z(313) = z(20)*z(258) + z(20)*z(271) + z(24)*z(268) + z(24)*z(269) + mB*(z(122)*z(184)+z(126)*z(183)+z(130)*z(182)) - z(22)*z(263) - z(22)*z(270);
z(314) = tx3 - rx3;
z(315) = ty3 - ry3;
z(316) = tz3 - rz3;
z(317) = tx4 - rx3;
z(318) = ty4 - ry3;
z(319) = tz4 - rz3;
z(320) = sx4 - rx3;
z(321) = sy4 - ry3;
z(322) = sz4 - rz3;
yA = q2 + vx1*z(14) + vy1*z(15) + vz1*z(16);
z(329) = vx2 - rx3;
z(330) = vy2 - ry3;
z(331) = vz2 - rz3;
yB = q2 + rx1*z(14) + ry1*z(15) + rz1*z(16) + z(329)*z(51) + z(330)*z(52) + z(331)*z(53);
z(327) = vz1*z(4) - vy1*z(10);
z(328) = vy1*z(6);
z(325) = vx1*z(6) - vz1*z(5);
z(326) = vx1*z(10) + vz1*z(9);
z(323) = vy1*z(5);
z(324) = -vx1*z(4) - vy1*z(9);
xAp = z(11)*(vz1*u6+z(11)*u1+z(14)*u2+z(327)*u4-z(9)*u3-z(328)*u5) + z(12)*(z(12)*u1-z(4)*u3-z(15)*u2-z(325)*u5-z(326)*u4) - z(13)*(vx1*u6-z(10)*u3-z(13)*u1-z(16)*u2-z(323)*u5-z(324)*u4);
z(340) = -z(22)*z(331) - z(24)*z(330);
z(341) = z(331)*z(41) - z(330)*z(43);
z(344) = z(113) + z(341);
z(342) = z(331)*z(55) - z(330)*z(56);
z(345) = z(114) + z(342);
z(343) = z(331)*z(58) - z(330)*z(59);
z(346) = z(115) + z(343);
z(336) = z(24)*z(329) - z(20)*z(331);
z(337) = z(329)*z(43) - z(331)*z(39);
z(347) = z(116) + z(337);
z(338) = z(329)*z(56) - z(331)*z(54);
z(348) = z(117) + z(338);
z(339) = z(329)*z(59) - z(331)*z(57);
z(349) = z(118) + z(339);
z(332) = z(20)*z(330) + z(22)*z(329);
z(333) = z(330)*z(39) - z(329)*z(41);
z(350) = z(119) + z(333);
z(334) = z(330)*z(54) - z(329)*z(55);
z(351) = z(120) + z(334);
z(335) = z(330)*z(57) - z(329)*z(58);
z(352) = z(121) + z(335);
xBp = z(48)*(z(340)*u7+z(48)*u1+z(51)*u2+z(54)*u3+z(344)*u6+z(345)*u4+z(346)*u5) + z(49)*(z(336)*u7+z(49)*u1+z(52)*u2+z(55)*u3+z(347)*u6+z(348)*u4+z(349)*u5) + z(50)*(z(332)*u7+z(50)*u1+z(53)*u2+z(56)*u3+z(350)*u6+z(351)*u4+z(352)*u5);
yAp = z(14)*(vz1*u6+z(11)*u1+z(14)*u2+z(327)*u4-z(9)*u3-z(328)*u5) - z(15)*(z(12)*u1-z(4)*u3-z(15)*u2-z(325)*u5-z(326)*u4) - z(16)*(vx1*u6-z(10)*u3-z(13)*u1-z(16)*u2-z(323)*u5-z(324)*u4);
yBp = z(51)*(z(340)*u7+z(48)*u1+z(51)*u2+z(54)*u3+z(344)*u6+z(345)*u4+z(346)*u5) + z(52)*(z(336)*u7+z(49)*u1+z(52)*u2+z(55)*u3+z(347)*u6+z(348)*u4+z(349)*u5) + z(53)*(z(332)*u7+z(50)*u1+z(53)*u2+z(56)*u3+z(350)*u6+z(351)*u4+z(352)*u5);
zAp = -z(4)*(z(12)*u1-z(4)*u3-z(15)*u2-z(325)*u5-z(326)*u4) - z(9)*(vz1*u6+z(11)*u1+z(14)*u2+z(327)*u4-z(9)*u3-z(328)*u5) - z(10)*(vx1*u6-z(10)*u3-z(13)*u1-z(16)*u2-z(323)*u5-z(324)*u4);
zBp = z(54)*(z(340)*u7+z(48)*u1+z(51)*u2+z(54)*u3+z(344)*u6+z(345)*u4+z(346)*u5) + z(55)*(z(336)*u7+z(49)*u1+z(52)*u2+z(55)*u3+z(347)*u6+z(348)*u4+z(349)*u5) + z(56)*(z(332)*u7+z(50)*u1+z(53)*u2+z(56)*u3+z(350)*u6+z(351)*u4+z(352)*u5);




%===========================================================================
function OpenOutputFilesAndWriteHeadings
FileIdentifier = fopen('FootContactOut.1', 'wt');   if( FileIdentifier == -1 ) error('Error: unable to open file FootContactOut.1'); end
fprintf( 1,             '%%\n' );
fprintf( 1,             '%%\n\n' );
fprintf(FileIdentifier, '%% FILE: FootContactOut.1\n%%\n' );
fprintf(FileIdentifier, '%%\n' );
fprintf(FileIdentifier, '%%\n\n' );
FileIdentifier = fopen('FootContactOut.2', 'wt');   if( FileIdentifier == -1 ) error('Error: unable to open file FootContactOut.2'); end
fprintf(FileIdentifier, '%% FILE: FootContactOut.2\n%%\n' );
fprintf(FileIdentifier, '%%\n' );
fprintf(FileIdentifier, '%%\n\n' );
FileIdentifier = fopen('FootContactOut.3', 'wt');   if( FileIdentifier == -1 ) error('Error: unable to open file FootContactOut.3'); end
fprintf(FileIdentifier, '%% FILE: FootContactOut.3\n%%\n' );
fprintf(FileIdentifier, '%%      yA             yB             xAp            xBp            yAp            yBp            zAp            zBp\n' );
fprintf(FileIdentifier, '%%    (UNITS)        (UNITS)        (UNITS)        (UNITS)        (UNITS)        (UNITS)        (UNITS)        (UNITS)\n\n' );



%===========================================================================
function DoCalculations
global   ec1 ec2 ec3 Grav IA1 IA2 IA3 IB1 IB2 IB3 mA mB p1 p2 rx1 rx2 rx3 ry1 ry2 ry3 rz1 rz2 rz3 sx1 sx2 sx3 sx4 sy1 sy2 sy3 sy4 sz1 sz2 sz3 sz4 tx1 tx2 tx3 tx4 ty1 ty2 ty3 ty4 tz1 tz2 tz3 tz4 ux1 ux2 uy1 uy2 uz1 uz2 vx1 vx2 vy1 vy2 vz1 vz2 FG1 FG2 FG3 FSA1 FSA2 FSA3 FSB1 FSB2 FSB3 q1 q2 q3 q4 q5 q6 q7 TG1 TG2 TG3 TSA1 TSA2 TSA3 TSB1 TSB2 TSB3 u1 u2 u3 u4 u5 u6 u7 u1p u2p u3p u4p u5p u6p u7p;
global   xAp xBp yA yAp yB yBp zAp zBp;
global   DEGtoRAD RADtoDEG z Amat bvec markers;




%===========================================================================
function Output = PrintUserOutput
global   ec1 ec2 ec3 Grav IA1 IA2 IA3 IB1 IB2 IB3 mA mB p1 p2 rx1 rx2 rx3 ry1 ry2 ry3 rz1 rz2 rz3 sx1 sx2 sx3 sx4 sy1 sy2 sy3 sy4 sz1 sz2 sz3 sz4 tx1 tx2 tx3 tx4 ty1 ty2 ty3 ty4 tz1 tz2 tz3 tz4 ux1 ux2 uy1 uy2 uz1 uz2 vx1 vx2 vy1 vy2 vz1 vz2 FG1 FG2 FG3 FSA1 FSA2 FSA3 FSB1 FSB2 FSB3 q1 q2 q3 q4 q5 q6 q7 TG1 TG2 TG3 TSA1 TSA2 TSA3 TSB1 TSB2 TSB3 u1 u2 u3 u4 u5 u6 u7 u1p u2p u3p u4p u5p u6p u7p;
global   xAp xBp yA yAp yB yBp zAp zBp;
global   DEGtoRAD RADtoDEG z Amat bvec markers;

Output(1)=0.0;
  Output(2)=0.0;

Output(3)=0.0;

Output(4)=yA;  Output(5)=yB;  Output(6)=xAp;  Output(7)=xBp;  Output(8)=yAp;  Output(9)=yBp;  Output(10)=zAp;  Output(11)=zBp;
FileIdentifier = fopen('all');
WriteOutput( 1,                 Output(1:2) );
WriteOutput( FileIdentifier(1), Output(1:2) );
WriteOutput( FileIdentifier(2), Output(3:3) );
WriteOutput( FileIdentifier(3), Output(4:11) );
Amat(1,1) = z(199);
Amat(1,2) = z(200);
Amat(1,3) = z(201);
Amat(1,4) = 0;
Amat(1,5) = 0;
Amat(1,6) = 0;
Amat(1,7) = 0;
Amat(2,1) = z(200);
Amat(2,2) = z(203);
Amat(2,3) = z(204);
Amat(2,4) = 0;
Amat(2,5) = 0;
Amat(2,6) = 0;
Amat(2,7) = 0;
Amat(3,1) = z(201);
Amat(3,2) = z(204);
Amat(3,3) = z(206);
Amat(3,4) = 0;
Amat(3,5) = 0;
Amat(3,6) = 0;
Amat(3,7) = 0;
Amat(4,1) = z(212);
Amat(4,2) = z(213);
Amat(4,3) = z(214);
Amat(4,4) = z(201);
Amat(4,5) = z(204);
Amat(4,6) = z(206);
Amat(4,7) = z(211);
Amat(5,1) = z(223);
Amat(5,2) = z(224);
Amat(5,3) = z(225);
Amat(5,4) = z(216);
Amat(5,5) = z(219);
Amat(5,6) = z(221);
Amat(5,7) = z(222);
Amat(6,1) = z(231);
Amat(6,2) = z(232);
Amat(6,3) = z(233);
Amat(6,4) = -z(12);
Amat(6,5) = z(15);
Amat(6,6) = z(4);
Amat(6,7) = z(230);
Amat(7,1) = 0;
Amat(7,2) = 0;
Amat(7,3) = 0;
Amat(7,4) = 0;
Amat(7,5) = 0;
Amat(7,6) = 0;
Amat(7,7) = z(235);
bvec(1) = z(279) + z(272)*u6p + z(273)*u1p + z(274)*u2p + z(275)*u4p + z(276)*u3p + z(277)*u5p + z(278)*u7p - FG1 - z(202);
bvec(2) = z(286) + z(274)*u1p + z(280)*u6p + z(281)*u2p + z(282)*u4p + z(283)*u3p + z(284)*u5p + z(285)*u7p - FG2 - z(205);
bvec(3) = z(292) + z(276)*u1p + z(283)*u2p + z(287)*u6p + z(288)*u4p + z(289)*u3p + z(290)*u5p + z(291)*u7p - FG3 - z(207);
bvec(4) = z(297) + z(275)*u1p + z(282)*u2p + z(288)*u3p + z(293)*u6p + z(294)*u4p + z(295)*u5p + z(296)*u7p - z(215) - FG1*z(208) - FG2*z(210) - FG3*z(209) - TG1*z(201) - TG2*z(204) - TG3*z(206);
bvec(5) = z(302) + z(277)*u1p + z(284)*u2p + z(290)*u3p + z(298)*u5p + z(299)*u4p + z(300)*u7p + z(301)*u6p - z(226) - FG1*z(220) - FG2*z(217) - FG3*z(218) - TG1*z(216) - TG2*z(219) - TG3*z(221);
bvec(6) = TG1*z(12) + z(308) + z(272)*u1p + z(280)*u2p + z(287)*u3p + z(304)*u6p + z(305)*u4p + z(306)*u7p + z(307)*u5p - z(234) - FG1*z(227) - FG2*z(228) - FG3*z(229) - TG2*z(15) - TG3*z(4);
bvec(7) = z(313) + z(309)*u7p + z(278)*u1p + z(285)*u2p + z(291)*u3p + z(310)*u6p + z(311)*u4p + z(312)*u5p - z(236);
markers(1,1) = q1 + tx1*z(11) + tz1*z(13) - ty1*z(12);
markers(1,2) = q2 + tx1*z(14) + ty1*z(15) + tz1*z(16);
markers(1,3) = q3 + ty1*z(4) + tz1*z(10) - tx1*z(9);
markers(1,4) = q1 + tx2*z(11) + tz2*z(13) - ty2*z(12);
markers(1,5) = q2 + tx2*z(14) + ty2*z(15) + tz2*z(16);
markers(1,6) = q3 + ty2*z(4) + tz2*z(10) - tx2*z(9);
markers(1,7) = q1 + sx1*z(11) + sz1*z(13) - sy1*z(12);
markers(1,8) = q2 + sx1*z(14) + sy1*z(15) + sz1*z(16);
markers(1,9) = q3 + sy1*z(4) + sz1*z(10) - sx1*z(9);
markers(1,10) = q1 + sx2*z(11) + sz2*z(13) - sy2*z(12);
markers(1,11) = q2 + sx2*z(14) + sy2*z(15) + sz2*z(16);
markers(1,12) = q3 + sy2*z(4) + sz2*z(10) - sx2*z(9);
markers(1,13) = q1 + sx3*z(11) + sz3*z(13) - sy3*z(12);
markers(1,14) = q2 + sx3*z(14) + sy3*z(15) + sz3*z(16);
markers(1,15) = q3 + sy3*z(4) + sz3*z(10) - sx3*z(9);
markers(1,16) = q1 + rx1*z(11) + rz1*z(13) + z(314)*z(48) + z(315)*z(49) + z(316)*z(50) - ry1*z(12);
markers(1,17) = q2 + rx1*z(14) + ry1*z(15) + rz1*z(16) + z(314)*z(51) + z(315)*z(52) + z(316)*z(53);
markers(1,18) = q3 + ry1*z(4) + rz1*z(10) + z(314)*z(54) + z(315)*z(55) + z(316)*z(56) - rx1*z(9);
markers(1,19) = q1 + rx1*z(11) + rz1*z(13) + z(317)*z(48) + z(318)*z(49) + z(319)*z(50) - ry1*z(12);
markers(1,20) = q2 + rx1*z(14) + ry1*z(15) + rz1*z(16) + z(317)*z(51) + z(318)*z(52) + z(319)*z(53);
markers(1,21) = q3 + ry1*z(4) + rz1*z(10) + z(317)*z(54) + z(318)*z(55) + z(319)*z(56) - rx1*z(9);
markers(1,22) = q1 + rx1*z(11) + rz1*z(13) + z(320)*z(48) + z(321)*z(49) + z(322)*z(50) - ry1*z(12);
markers(1,23) = q2 + rx1*z(14) + ry1*z(15) + rz1*z(16) + z(320)*z(51) + z(321)*z(52) + z(322)*z(53);
markers(1,24) = q3 + ry1*z(4) + rz1*z(10) + z(320)*z(54) + z(321)*z(55) + z(322)*z(56) - rx1*z(9);



%===========================================================================
function WriteOutput( fileIdentifier, Output )
numberOfOutputQuantities = length( Output );
if numberOfOutputQuantities > 0,
  for i=1:numberOfOutputQuantities,
    fprintf( fileIdentifier, ' %- 14.6E', Output(i) );
  end
  fprintf( fileIdentifier, '\n' );
end



%===========================================================================
function CloseOutputFilesAndTerminate
FileIdentifier = fopen('all');
fclose( FileIdentifier(1) );
fclose( FileIdentifier(2) );
fclose( FileIdentifier(3) );
fprintf( 1, '\n Output is in the files FootContactOut.i  (i=1,2,3)\n' );
fprintf( 1, ' The output quantities and associated files are listed in the file FootContactOut.dir\n\n' );
