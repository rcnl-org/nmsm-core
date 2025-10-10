% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the normalized force
%
% (Array of number) -> (Array of number)
% returns normalized force  

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

function normalizedForce = forceVelocityCurve(...
    normalizedMuscleFiberVelocity)

d1 = -32.54607148305652;
d2 = 22.180805935541066;
d3 = 18.810486818973832;
d4 = 6.32671625780895;
d5 = -0.2767160849384081;
d6 = 8.053310381650647;
normalizedForce = d1 + d2 * atan(d3 + d4 * atan(d5 + d6 * ...
    normalizedMuscleFiberVelocity));
end