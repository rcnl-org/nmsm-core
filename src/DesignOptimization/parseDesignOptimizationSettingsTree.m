% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Design Optimizatoin settings XML file.
%
% (struct) -> (struct, struct)
% returns the input values for Design Optimization

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
    parseDesignOptimizationSettingsTree(settingsTree)
inputs = parseTreatmentOptimizationInputs(settingsTree);
inputs = parseDesignSettings(settingsTree, inputs);
inputs = getInputs(settingsTree, inputs);
params = parseTreatmentOptimizationParams(settingsTree);
inputs = modifyModelForces(inputs);
inputs = updateMuscleModelProperties(inputs);
end

function inputs = getInputs(tree, inputs)
import org.opensim.modeling.Storage
if strcmpi(inputs.controllerType, 'synergy')
inputs.synergyWeights = parseTreatmentOptimizationStandard(...
    {getTextFromField(getFieldByName(tree, 'synergy_vectors_file'))});
end
inputs.systemFns = parseSpaceSeparatedList(tree, "model_functions");
parameterTree = getFieldByNameOrError(tree, "RCNLParameterTermSet");
if isstruct(parameterTree) && isfield(parameterTree, "RCNLParameterTerm")
    inputs.userDefinedVariables = parseRcnlCostTermSet( ...
        parameterTree.RCNLParameterTerm);
else
    inputs.userDefinedVariables = {};
end
end

function inputs = parseDesignSettings(tree, inputs)
finalTimeRange = getFieldByName(tree, ...
    'final_time_range');
if(isstruct(finalTimeRange))
    inputs.finalTimeRange = getDoubleFromField(finalTimeRange);
end
inputs.enableExternalTorqueControl = getBooleanLogicFromField( ...
    getFieldByName(tree, "enable_external_torque_controls"));
if inputs.enableExternalTorqueControl
    inputs.externalControlTorqueNames = parseSpaceSeparatedList(tree, ...
        "external_control_coordinate_list");
    inputs.numExternalTorqueControls = ...
        length(inputs.externalControlTorqueNames);
    inputs.maxExternalTorqueControls = getDoubleFromField( ...
        getFieldByNameOrError(tree, ...
        'external_torque_control_multiple'));
end
end

