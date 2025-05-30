% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (string) -> (None)
% Start Design Optimization from settings file to preview integrated terms 

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

function IntegratedQuantitiesPreviewTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
verifyVersion(settingsTree, "DesignOptimizationTool");
[inputs, params] = parseDesignOptimizationSettingsTree(settingsTree);
inputs = normalizeSynergyData(inputs);
inputs = setupMuscleSynergies(inputs);
inputs = setupTorqueControls(inputs);
inputs = makeTreatmentOptimizationInputs(inputs, params);
[setup, ~] = convertToGpopsInputs(inputs, params);
displayIntegratedQuantitesPreview(setup, inputs);
end

function displayIntegratedQuantitesPreview(setup, inputs)
integral = setup.guess.phase.integral;
index = length(integral);
metabolic = valueOrAlternate(inputs, 'calculateMetabolicCost', false);
braking = valueOrAlternate(inputs, 'calculateBrakingImpulse', false);
propulsive = valueOrAlternate(inputs, 'calculatePropulsiveImpulse', false);
if propulsive
    disp("Propulsive impulses: " + ...
        integral(index - length(inputs.contactSurfaces) + 1 : index));
    index = index - length(inputs.contactSurfaces);
end
if braking
    disp("Braking impulses: " + ...
        integral(index - length(inputs.contactSurfaces) + 1 : index));
    index = index - length(inputs.contactSurfaces);
end
if metabolic
    disp("Total metabolic cost: " + integral(index));
    index = index - 1;
end
end
