% This function is part of the NMSM Pipeline, see file for full license.
%
% There are two controllers that can be used to solve optimal control
% problems in the NMSM Pipeline. This function parses the synergy
% controller settings inside <RCNLSynergyController>
%
% (struct) -> (struct)
% parses synergy controller settings from XML tree

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

function inputs = parseSynergyController(tree, inputs)
inputs.synergyGroups = inputs.osimx.synergyGroups;
inputs.numSynergies = getNumSynergies(inputs.synergyGroups);
inputs.numSynergyWeights = getNumSynergyWeights(inputs.synergyGroups);
inputs.surrogateModelCoordinateNames = parseSpaceSeparatedList(tree, ...
    "states_coordinate_list");
inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
    inputs.surrogateModelCoordinateNames);
inputs.numMuscles = length(inputs.muscleNames);
inputs.epsilon = str2double(parseElementTextByNameOrAlternate(tree, ...
    "epsilon", "1e-4"));
inputs.vMaxFactor = str2double(parseElementTextByNameOrAlternate(tree, ...
    "maximum_shortening_velocity_multiplier", "10"));
surrogateModelCoefficients = load(getTextFromField(getFieldByName(tree, ...
        'surrogate_model_coefficients')));
inputs.coefficients = surrogateModelCoefficients.coefficients;
inputs.optimizeSynergyVectors = getBooleanLogic(...
    parseElementTextByNameOrAlternate(tree, "optimize_synergy_vectors", 0));
inputs.maxControlSynergyActivations = parseDoubleOrAlternate(tree, ...
    'maximum_allowable_synergy_activation', 10);
inputs.maxParameterSynergyWeights = parseDoubleOrAlternate(tree, ...
    'maximum_allowable_synergy_vector_weight', 2);
inputs = getModelOrOsimxInputs(inputs);
end

