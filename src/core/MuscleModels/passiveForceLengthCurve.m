% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the normalized passive force
%
% (Array of number) -> (Array of number)
% returns normalized passive force  

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

function normalizedPassiveForce = passiveForceLengthCurve(...
    normalizedMuscleFiberLength)

e1 = 0.232000797810576;
e2 = 12.438535493526128;
e3 = 1.329470475731338;
% Result of exp can be greater than a double can store
% normalizedPassiveForce = e1 * log(exp(e2 * (... 
%     normalizedMuscleFiberLength - e3)) + 1);

fiberLengthPower = e2 * (normalizedMuscleFiberLength - e3);
normalizedPassiveForce = e1 * (log(exp(0.5 * fiberLengthPower) + ...
    exp(-0.5 * fiberLengthPower)) + log(exp(0.5 * fiberLengthPower)));
end