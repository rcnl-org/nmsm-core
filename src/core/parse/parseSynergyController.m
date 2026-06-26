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
inputs.surrogateModelCoordinateNames = parseSpaceSeparatedList(tree, ...
    "surrogate_model_coordinate_list");
surrogateCoordintateMuscleNames = getMusclesFromCoordinates( ...
    inputs.model, inputs.surrogateModelCoordinateNames);
% Restrict muscles to those included in synergy sets
synergyMuscleNames = string([]);
synergyGroups = getFieldByNameOrAlternate(inputs.osimx, ...
    "synergyGroups", {});
for i = 1 : length(synergyGroups)
    synergyMuscleNames = [synergyMuscleNames synergyGroups{i}.muscleNames];
end
inputs.synergyMuscleNames = intersect(synergyMuscleNames, ...
    surrogateCoordintateMuscleNames, 'stable'); % Stable added by Li to 
    % keep muscle names in correct order
inputs.numSynergyMuscles = length(inputs.synergyMuscleNames);
inputs.optimizeSynergyVectors = getBooleanLogic(...
    parseElementTextByNameOrAlternate(tree, "optimize_synergy_vectors", 0));
inputs.maxControlSynergyActivations = parseDoubleOrAlternate(tree, ...
    'maximum_allowable_synergy_activation', 10);
inputs.synergyNormalizationMethod = getTextFromField( ...
    getFieldByNameOrAlternate(tree, ...
    'synergy_vector_normalization_method', "sum"));
inputs.synergyNormalizationValue = getDoubleFromField( ...
    getFieldByNameOrAlternate(tree, ...
    'synergy_vector_normalization_value', 1));
end
