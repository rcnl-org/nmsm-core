% This function is part of the NMSM Pipeline, see file for full license.
%
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                                                 %
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

function inputs = parseTreatmentOptimizationDesignVariableBounds( ...
    tree, inputs)
inputs.jointPositionsMultiple = parseDoubleOrAlternate(tree, ...
    'joint_positions_multiple', 2);
inputs.jointVelocitiesMultiple = parseDoubleOrAlternate(tree, ...
    'joint_velocities_multiple', 1.5);
inputs.jointAccelerationsMultiple = parseDoubleOrAlternate(tree, ...
    'joint_accelerations_multiple', 1);
inputs.controlJerksMultiple = parseDoubleOrAlternate(tree, ...
    'joint_jerks_multiple', 1);
inputs.maxControlSynergyActivations = parseDoubleOrAlternate(tree, ...
    'synergy_activations_max', 10);
inputs.maxParameterSynergyWeights = parseDoubleOrAlternate(tree, ...
    'synergy_weights_max', 2);
inputs.maxControlTorquesMultiple = parseDoubleOrAlternate(tree, ...
    'torque_controls_max', 1);
end
