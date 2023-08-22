% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Verification Optimizatoin settings XML file.
%
% (struct) -> (struct, struct)
% returns the input values for Verification Optimization

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

function [inputs, params] = ...
    parseVerificationOptimizationSettingsTree(settingsTree)
inputs = getTreatmentOptimizationInputs(settingsTree);
inputs = parseTreatmentOptimizationDesignVariableBounds(settingsTree, ...
    inputs);
inputs = getInputs(settingsTree);
inputs.toolName = "VerificationOptimization";
params = getParams(settingsTree);
inputs = modifyModelForces(inputs);
end

function inputs = getInputs(tree)
import org.opensim.modeling.Storage
if strcmpi(inputs.controllerType, 'synergy_driven')
inputs.synergyWeights = parseTreatmentOptimizationStandard(...
    {getTextFromField(getFieldByName(tree, 'synergy_vectors_file'))});
end
end

function params = getParams(tree)
params.solverSettings = getOptimalControlSolverSettings(...
    getTextFromField(getFieldByName(tree, 'optimal_control_settings_file')));
end
