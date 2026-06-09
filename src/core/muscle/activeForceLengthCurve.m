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

b11 = 0.8174335195120225;
b21 = 1.054348561163096;
b31 = 0.16194288662761705;
b41 = 0.06381565266097716;
b12 = 0.43130780147182907;
b22 = 0.7163004817144202;
b32 = -0.029060905806803296;
b42 = 0.19835014521987723;
b13 = 0.1;
b23 = 1.0;
b33 = 0.353553390593274; % 0.5 * sqrt(0.5)
b43 = 0.0;
normalizedActiveForce = b11 * exp(-0.5 * (normalizedMuscleFiberLength - ...
    b21) .^ 2 ./ (b31 + b41 * normalizedMuscleFiberLength) .^ 2) + b12 * ...
    exp(-0.5 * (normalizedMuscleFiberLength - b22) .^ 2 ./ (b32 + b42 * ...
    normalizedMuscleFiberLength) .^ 2) + b13 * exp(-0.5 * ...
    (normalizedMuscleFiberLength - b23) .^ 2 ./ (b33 + b43 * ...
    normalizedMuscleFiberLength) .^ 2);
end