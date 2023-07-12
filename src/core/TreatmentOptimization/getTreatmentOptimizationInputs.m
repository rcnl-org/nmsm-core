% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct from the
% settings XML file common to all treatment optimizatin modules (trackning,
% verification, and design optimization).
%
% (struct) -> (struct, struct)
% returns the input values for all treatment optimization modules

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function inputs = getTreatmentOptimizationInputs(tree)
inputs.resultsDirectory = getTextFromField(getFieldByName(tree, ...
    'results_directory'));
if(isempty(inputs.resultsDirectory)); inputs.resultsDirectory = pwd; end
inputs.controllerType = getTextFromField(getFieldByNameOrError(tree, ...
    'type_of_controller'));
inputs.model = parseModel(tree);
inputs.osimx = parseOsimxFile(getTextFromField(getFieldByName(tree, ...
    'osimx_file')));
if strcmp(inputs.controllerType, 'synergy_driven')
    inputs.synergyGroups = getSynergyGroups(tree, Model(inputs.model));
    inputs.numSynergies = getNumSynergies(inputs.synergyGroups);
    inputs.numSynergyWeights = getNumSynergyWeights(inputs.synergyGroups);
    inputs.surrogateModelCoordinateNames = parseSpaceSeparatedList(tree, ...
        "coordinate_list");
    inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
        inputs.surrogateModelCoordinateNames);
    inputs.numMuscles = length(inputs.muscleNames);
    inputs.epsilon = str2double(parseElementTextByNameOrAlternate(tree, ...
        "epsilon", "1e-4"));
    inputs.vMaxFactor = str2double(parseElementTextByNameOrAlternate(tree, ...
        "v_max_factor", "10"));
    surrogateModelCoefficients = load(getTextFromField(getFieldByName(tree, ...
        'surrogate_model_coefficients')));
    inputs.coefficients = surrogateModelCoefficients.coefficients;
    inputs = getModelOrOsimxInputs(inputs);
elseif strcmp(inputs.controllerType, 'torque_driven')
    inputs.controlTorqueNames = parseSpaceSeparatedList(tree, ...
        "coordinate_list");
    inputs.numTorqueControls = length(inputs.controlTorqueNames);
end
inputs.optimizeSynergyVectors = getBooleanLogic(...
    parseElementTextByNameOrAlternate(tree, "optimize_synergy_vectors", 0));
inputs = parseTreatmentOptimizationDataDirectory(tree, inputs);
inputs.initialGuess = getGpopsInitialGuess(tree);
inputs.experimentalTime = inputs.experimentalTime / ...
    inputs.experimentalTime(end);
inputs = reorderTreatmentOptimizationDataByCoordinates(inputs);
inputs.costTerms = parseRcnlCostTermSet( ...
    getFieldByNameOrError(tree, 'RCNLCostTermSet').RCNLCostTerm);
inputs.path = getPathConstraintTerms(tree);
inputs.terminal = getTerminalConstraintTerms(tree);
contactSurfaces = getFieldByName(inputs.osimx, "contactSurface");
if (isstruct(contactSurfaces) || iscell(contactSurfaces)) && ...
        isfield(inputs, "grfFileName")
    inputs.contactSurfaces = prepareGroundContactSurfaces(inputs.model, ...
        contactSurfaces, inputs.grfFileName);
else
    inputs.contactSurfaces = {};
end
end
