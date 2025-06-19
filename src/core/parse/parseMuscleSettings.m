% This function is part of the NMSM Pipeline, see file for full license.
%
% There are multiple controllers that can be used to solve optimal control
% problems in the NMSM Pipeline. This function parses the muscle
% model settings inside <RCNLMuscleModel> for two of those controllers.
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

function inputs = parseMuscleSettings(tree, inputs)
inputs.muscleNames = unique([valueOrAlternate(inputs, ...
    'synergyMuscleNames', []), valueOrAlternate(inputs, ...
    'individualMuscleNames', [])], 'stable');
inputs.numMuscles = length(inputs.muscleNames);
inputs.surrogateModelCoordinateNames = parseSpaceSeparatedList(tree, ...
    "surrogate_model_coordinate_list");
inputs.epsilon = str2double(parseElementTextByNameOrAlternate(tree, ...
    "surrogate_model_coordinate_value_threshold", "1e-4"));
inputs.polynomialDegree = str2double(parseElementTextByNameOrAlternate( ...
    tree, "surrogate_model_polynomial_degree", "5"));
inputs.vMaxFactor = str2double(parseElementTextByNameOrAlternate(tree, ...
    "maximum_shortening_velocity_multiplier", "10"));
inputs = getModelOrOsimxInputs(inputs);
inputs.surrogateModelFileName = parseElementTextByNameOrAlternate(tree, ...
    "surrogate_model_file_name", "surrogateMuscles.mat");
inputs.useActivationSaturation = strcmpi( ...
    parseElementTextByNameOrAlternate(tree, ...
    "use_activation_saturation", "true"), "true");
inputs.activationSaturationSharpness = str2double( ...
    parseElementTextByNameOrAlternate(tree, ...
    "activation_saturation_sharpness", "600"));
end
