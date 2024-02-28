% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns an integrand cost for metabolic cost normalized by
% distance. 
%
% (struct, struct, struct, struct) -> (Array of double)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function cost = calcMetabolicCostPerDistanceGoalIntegrand( ...
    modeledValues, values, inputs, costTerm)
assert(isfield(modeledValues, 'muscleActivations'), "Muscle " + ...
    "activations are required for metabolic cost calculations.")
rawCost = calcMetabolicCost(values.time, values.positions, ...
    modeledValues.muscleActivations, inputs);
massCenterVelocity = mean(calcMassCenterVelocity(values, inputs.model, ...
    inputs.coordinateNames), 1);
massCenterVelocity = massCenterVelocity(1);
beltSpeed = 0;
if ~isempty(inputs.contactSurfaces)
    for i = 1 : length(inputs.contactSurfaces)
        beltSpeed = beltSpeed + inputs.contactSurfaces{i}.beltSpeed;
    end
    beltSpeed = beltSpeed / length(inputs.contactSurfaces);
end

cost = (rawCost - costTerm.errorCenter) / values.time(end) ...
    / (massCenterVelocity + beltSpeed);
end