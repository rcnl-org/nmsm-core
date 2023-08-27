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

function inputs = parseTreatmentOptimizationInputs(tree)
inputs.toolName = findToolName(tree);
inputs.resultsDirectory = getTextFromField(getFieldByName(tree, ...
    'results_directory'));
if(isempty(inputs.resultsDirectory)); inputs.resultsDirectory = pwd; end
inputs.controllerType = parseControllerType(tree);
inputs.model = parseModel(tree);
inputs.osimx = parseOsimxFile(getTextFromField(getFieldByName(tree, ...
    'input_osimx_file')));
if strcmp(inputs.controllerType, 'synergy')
   inputs = parseSynergyController(tree, inputs);
elseif strcmp(inputs.controllerType, 'torque')
    inputs = parseTorqueController(tree, inputs);
end
inputs = parseTreatmentOptimizationDataDirectory(tree, inputs);
inputs = parseOptimalControlSolverSettings( ...
    getTextFromField(getFieldByNameOrError(tree, ...
    'optimal_control_solver_settings_file')), inputs);
inputs.costTerms = parseRcnlCostTermSet( ...
    getFieldByNameOrError(tree, 'RCNLCostTermSet').RCNLCostTerm);
[inputs.path, inputs.terminal] = parseRcnlConstraintTermSet( ...
    getFieldByNameOrError(tree, 'RCNLConstraintTermSet') ...
    .RCNLConstraintTerm, inputs.toolName, inputs.controllerType);
inputs.contactSurfaces = parseGroundContactSurfaces(inputs);
end