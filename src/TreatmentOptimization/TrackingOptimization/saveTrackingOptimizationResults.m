% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves and prints the unscaled results from Tracking
% Optimization.
%
% (struct, struct) -> (None)
% Prints tracking optimization results

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Spencer Williams                               %
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

function saveTrackingOptimizationResults(solution, inputs)
values = makeGpopsValuesAsStruct(solution.solution.phase, inputs);
if strcmp(inputs.controllerType, "synergy")
    values = normalizeSynergySolution(values, inputs);
end
saveTreatmentOptimizationResults(solution, inputs, values);
end

function values = normalizeSynergySolution(values, inputs)
values.controllerType = inputs.controllerType;
values.initialSynergyControls = values.controlSynergyActivations;
values.synergyNormalizationMethod = inputs.synergyNormalizationMethod;
values.synergyNormalizationValue = inputs.synergyNormalizationValue;
values = normalizeSynergyData(values);
values.controlSynergyActivations = values.initialSynergyControls;
end
