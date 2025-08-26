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

function inputs = parseTreatmentOptimizationDesignVariableBounds( ...
    tree, inputs)
inputs.jointPositionsMultiple = parseDoubleOrAlternate(tree, ...
    'joint_position_range_scale_factor', 2);
inputs.jointVelocitiesMultiple = parseDoubleOrAlternate(tree, ...
    'joint_velocity_range_scale_factor', 1.5);
inputs.jointAccelerationsMultiple = parseDoubleOrAlternate(tree, ...
    'joint_acceleration_range_scale_factor', 1);
inputs.jointJerksMultiple = parseDoubleOrAlternate(tree, ...
    'joint_jerk_range_scale_factor', 1);
inputs.jointPositionsMinRange = parseDoubleOrAlternate(tree, ...
    'joint_position_minimum_range', 0);
inputs.jointVelocitiesMinRange = parseDoubleOrAlternate(tree, ...
    'joint_velocity_minimum_range', 0);
inputs.jointAccelerationsMinRange = parseDoubleOrAlternate(tree, ...
    'joint_acceleration_minimum_range', 0);
inputs.jointJerksMinRange = parseDoubleOrAlternate(tree, ...
    'joint_jerk_minimum_range', 0);
if inputs.useControlDerivatives
    inputs.userControlDerivativesMultiple = parseDoubleOrAlternate( ...
        tree, 'user_defined_control_derivatives_range_scale_factor', 1);
    inputs.muscleControlDerivativesMultiple = parseDoubleOrAlternate( ...
        tree, 'muscle_control_derivatives_range_scale_factor', 1);
    inputs.synergyControlDerivativesMultiple = parseDoubleOrAlternate( ...
        tree, 'synergy_control_derivatives_range_scale_factor', 1);
    inputs.userControlDerivativesMinRange = parseDoubleOrAlternate( ...
        tree, 'user_defined_control_derivatives_minimum_range', 0);
    inputs.muscleControlDerivativesMinRange = parseDoubleOrAlternate( ...
        tree, 'muscle_control_derivatives_minimum_range', 0);
    inputs.synergyControlDerivativesMinRange = parseDoubleOrAlternate( ...
        tree, 'synergy_control_derivatives_minimum_range', 0);
end
end
