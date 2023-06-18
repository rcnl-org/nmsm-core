% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns all of the cost term calculation methods including
% user_defined and existing cost term values. Tools use this function for
% the discrete and continuous cost calculations.
%
% inputs:
% costTermType - one of ["discrete", "continuous"]
% toolName - one of ["TrackingOptimization", "TreatmentOptimization", ...
%   "DesignOptimization"]
%
% (string, string) -> (struct of function handles, Array of string)
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

function [costTermCalculations, allowedTypes] = ...
    generateCostTermStruct(costTermType, toolName)
allowedTypes = getAllowedTypes(costTermType, toolName);
costTermCalculations = getCostTermCalculations(costTermType);
end

function allowedTypes = getAllowedTypes(costTermType, toolName)
if strcmp(costTermType, "continuous")
    switch toolName
        case "TrackingOptimization"
            allowedTypes = [ ...
                "coordinate_tracking", ...
                "inverse_dynamics_load_tracking", ...
                "external_force_tracking", ...
                "external_moment_tracking", ...
                "muscle_activation_tracking", ...
                "joint_jerk_minimization", ...
                ];
        case "VerificationOptimization"
            allowedTypes = [ ...
                "coordinate_tracking", ...
                "controller_tracking", ...
                "joint_jerk_minimization", ...
            ];
        case "DesignOptimization"
            allowedTypes = [ ...
                "coordinate_tracking", ...
                "controller_tracking", ...
                "joint_jerk_minimization", ...
                "metabolic_cost_minimization" ...
                "propulsive_force_maximization" ...
                "propulsive_force_minimization" ...
                "breaking_force_maximization" ...
                "breaking_force_minimization" ...
                "step_length_maximization" ... 
                "step_length_asymmetry_minimization" ...
                "single_support_time_maximization" ...
                "single_support_time_goal" ...
                "step_time_asymmetry_minimization" ...
                "joint_power_minimization" ...
                "trailing_limb_angle_minimization" ...
                "trailing_limb_angle_maximization" ...
                "user_defined", ...
                ];
        otherwise
            throw(MException('', ['Tool name' toolName 'is not valid']))
    end
elseif strcmp(costTermType, "discrete")
    switch toolName
        case "TrackingOptimization"
            allowedTypes = [ ...

            ];
        case "VerificationOptimization"
            allowedTypes = [ ...

            ];
        case "DesignOptimization"
            allowedTypes = [ ...
                "synergy_vector_tracking", ...
                "user_defined", ...
                ];
        otherwise
            throw(MException('', ['Tool name' toolName 'is not valid']))
    end
else
    throw(MException('', ['Cost term type ' costTermType ...
        ' is not valid, must be continuous or discrete']))
end
end

function costTermCalculations = getCostTermCalculations(costTermType)

costTermCalculations.coordinate_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingCoordinateIntegrand( ...
    auxdata, ...
    values.time/values.time(end), ...
    values.statePositions, ...
    costTerm.coordinate ...
    );

costTermCalculations.controller_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingControllerIntegrand( ...
    auxdata, ...
    values, ...
    values.time/values.time(end), ...
    costTerm.controller ...
    );

costTermCalculations.joint_jerk_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingJointJerkIntegrand( ...
    values.controlJerks, ...
    auxdata, ...
    costTerm.coordinate ...
    );

costTermCalculations.metabolic_cost_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingMetabolicCost( ...
    modeledValues.metabolicCost);

costTermCalculations.inverse_dynamics_load_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingInverseDynamicLoadsIntegrand( ...
    auxdata, ...
    values.time, ...
    modeledValues.inverseDynamicMoments, ...
    costTerm.load ...
    );

costTermCalculations.external_force_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingExternalForcesIntegrand( ...
    auxdata, ...
    modeledValues.groundReactionsLab.forces, ...
    values.time, ...
    costTerm.force);

costTermCalculations.external_moment_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingExternalMomentsIntegrand( ...
    auxdata, ...
    modeledValues.groundReactionsLab.moments, ...
    values.time, ...
    costTerm.moment);

costTermCalculations.muscle_activation_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingMuscleActivationIntegrand( ...
    modeledValues.muscleActivations, ...
    values.time, ...
    auxdata, ...
    costTerm.muscle);

costTermCalculations.propulsive_force_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingPropulsiveForceIntegrand( ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.propulsive_force_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingPropulsiveForceIntegrand( ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.breaking_force_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingBreakingForceIntegrand( ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.breaking_force_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingBreakingForceIntegrand( ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.step_length_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingStepLengthIntegrand( ...
    values, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.step_length_asymmetry_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcStepLengthAsymmetryIntegrand( ...
    values, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.single_support_time_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingSingleSupportTimeIntegrand( ...
    values, ...
    modeledValues, ...
    auxdata, ...
    costTerm);


costTermCalculations.single_support_time_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcGoalSingleSupportTimeIntegrand( ...
    values, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.step_time_asymmetry_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcStepTimeAsymmetryIntegrand( ...
    values, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.joint_power_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingJointPowerIntegrand( ...
    values.stateVelocities, ...
    modeledValues.inverseDynamicMoments, ...
    auxdata, ...
    costTerm.load ...
    );

costTermCalculations.trailing_limb_angle_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingTrailingLimbAngleIntegrand( ...
    values, ...
    modeledValues, ...
    auxdata, ...
    costTerm ...
    );

costTermCalculations.trailing_limb_angle_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingTrailingLimbAngleIntegrand( ...
    values, ...
    modeledValues, ...
    auxdata, ...
    costTerm ...
    );

costTermCalculations.synergy_vector_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingSynergyVectorsDiscrete( ...
    values.synergyWeights, ...
    auxdata, ...
    costTerm);

costTermCalculations.user_defined = @(values, modeledValues, auxdata, costTerm) ...
    userDefinedFunction(values, ...
    modeledValues, ...
    auxdata, ...
    costTerm, ...
    costTermType);
end

function output =  ...
    userDefinedFunction(values, modeledValues, auxdata, costTerm, costTermType)
output = [];
if strcmp(costTerm.cost_term_type, costTermType)
    fn = str2func(costTerm.function_name);
    output = fn(values, modeledValues, auxdata, costTerm);
end
end
