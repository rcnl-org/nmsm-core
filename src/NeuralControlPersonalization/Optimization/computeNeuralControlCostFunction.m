% This function is part of the NMSM Pipeline, see file for full license.
%
% The objective function fmincon calls each iteration. Expands the
% bilateral-symmetry-mirrored design vector (when enabled) back to its
% full length before delegating to calcNcpCost.m.
%
% (Array of number, struct, struct) -> (number)
% Wraps calcNcpCost.m as fmincon's objective function

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

function cost = computeNeuralControlCostFunction(values, inputs, params)
if ~inputs.optimize_synergy_vectors
    values = [inputs.fixedSynergyVectorFlat; values];
elseif inputs.enforce_bilateral_symmetry
    weightsPart = values(1:inputs.numWeightsPerGroup(1));
    values = [weightsPart; values];
end
cost = calcNcpCost(values, inputs, params);
end
