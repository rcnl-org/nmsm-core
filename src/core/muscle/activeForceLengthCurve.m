% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the normalized active force
%
% (Array of number) -> (Array of number)
% returns normalized active force  

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

function normalizedActiveForce = activeForceLengthCurve(...
    normalizedMuscleFiberLength)

b11 = 0.814483478343008;
b21 = 1.055033428970575;
b31 = 0.162384573599574;
b41 = 0.063303448465465;
b12 = 0.433004984392647;
b22 = 0.716775413397760;
b32 = -0.029947116970696;
b42 = 0.200356847296188;
b13 = 0.1;
b23 = 1;
b33 = 0.5 * sqrt(0.5);
b43 = 0;
normalizedActiveForce = b11 * exp(-0.5 * (normalizedMuscleFiberLength - ...
    b21) .^ 2 ./ (b31 + b41 * normalizedMuscleFiberLength) .^ 2) + b12 * ...
    exp(-0.5 * (normalizedMuscleFiberLength - b22) .^ 2 ./ (b32 + b42 * ...
    normalizedMuscleFiberLength) .^ 2) + b13 * exp(-0.5 * ...
    (normalizedMuscleFiberLength - b23) .^ 2 ./ (b33 + b43 * ...
    normalizedMuscleFiberLength) .^ 2);
end