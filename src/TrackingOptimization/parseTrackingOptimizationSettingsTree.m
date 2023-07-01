% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Tracking Optimizatoin settings XML file.
%
% (struct) -> (struct, struct)
% returns the input values for Tracking Optimization

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

function [inputs, params, resultsDirectory] = ...
    parseTrackingOptimizationSettingsTree(settingsTree)
inputs = getTreatmentOptimizationInputs(settingsTree);
inputs = getDesignVariableBounds(settingsTree, inputs);
params = getParams(settingsTree);
inputs = modifyModelForces(inputs);
end

function inputs = getDesignVariableBounds(tree, inputs)
designVariableTree = getFieldByNameOrError(tree, ...
    'RCNLDesignVariableBoundsTerms');
jointPositionsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_positions_multiple');
if(isstruct(jointPositionsMultiple))
    inputs.statePositionsMultiple = getDoubleFromField(jointPositionsMultiple);
end
jointVelocitiesMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_velocities_multiple');
if(isstruct(jointVelocitiesMultiple))
    inputs.stateVelocitiesMultiple = getDoubleFromField(jointVelocitiesMultiple);
end
jointAccelerationsMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_accelerations_multiple');
if(isstruct(jointAccelerationsMultiple))
    inputs.stateAccelerationsMultiple = ...
        getDoubleFromField(jointAccelerationsMultiple);
end
jointJerkMultiple = getFieldByNameOrError(designVariableTree, ...
    'joint_jerks_multiple');
if(isstruct(jointJerkMultiple))
    inputs.controlJerksMultiple = getDoubleFromField(jointJerkMultiple);
end
if strcmp(inputs.controllerType, 'synergy_driven')
maxControlSynergyActivations = getFieldByNameOrError(designVariableTree, ...
    'synergy_activations_max');
if(isstruct(maxControlSynergyActivations))
    inputs.maxControlSynergyActivations = ...
        getDoubleFromField(maxControlSynergyActivations);
end
maxParameterSynergyWeights = getFieldByNameOrError(designVariableTree, ...
    'synergy_weights_max');
if(isstruct(maxParameterSynergyWeights))
    inputs.maxParameterSynergyWeights = ...
        getDoubleFromField(maxParameterSynergyWeights);
end
else 
maxControlTorques = getFieldByNameOrError(designVariableTree, ...
    'torque_controls_max');
if(isstruct(maxControlTorques))
    inputs.maxControlTorquesMultiple = getDoubleFromField(maxControlTorques);
end
end
inputs.toolName = "TrackingOptimization";
end

function params = getParams(tree)
params.solverSettings = getOptimalControlSolverSettings(...
    getTextFromField(getFieldByName(tree, 'optimal_control_settings_file')));
end