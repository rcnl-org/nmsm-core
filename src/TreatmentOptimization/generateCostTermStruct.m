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
                "generalized_coordinate_tracking", ...
                "generalized_speed_tracking", ...
                "marker_position_tracking", ...
                "inverse_dynamics_load_tracking", ...
                "inverse_dynamics_load_minimization", ...
                "kinetic_inconsistency_minimization", ...
                "external_force_tracking", ...
                "external_moment_tracking", ...
                "muscle_activation_tracking", ...
                "joint_jerk_minimization", ...
                ];
        case "VerificationOptimization"
            allowedTypes = [ ...
                "generalized_coordinate_tracking", ...
                "generalized_speed_tracking", ...
                "marker_position_tracking", ...
                "controller_tracking", ...
                "joint_jerk_minimization", ...
            ];
        case "DesignOptimization"
            allowedTypes = [ ...
                "generalized_coordinate_tracking", ...
                "generalized_speed_tracking", ...
                "marker_position_tracking", ...
                "inverse_dynamics_load_tracking", ...
                "external_force_tracking", ...
                "external_moment_tracking", ...
                "muscle_activation_tracking", ...
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
                "joint_energy_generation_goal" ...
                "joint_energy_absorption_goal" ...
                "propulsive_impulse_goal" ...
                "braking_impulse_goal" ...
                "trailing_limb_angle_minimization" ...
                "trailing_limb_angle_maximization" ...
                "muscle_activation_minimization" ...
                "muscle_activation_maximization" ...
                "center_mass_velocity_x_minimization" ...
                "center_mass_velocity_y_minimization" ...
                "center_mass_velocity_z_minimization" ...
                "kinematic_symmetry" ...
                "walking_speed_goal" ...
                "external_torque_control_minimization" ...
                "angular_momentum_minimization" ...
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
                "synergy_vector_tracking" ...
                "belt_speed_goal" ...
                "user_defined" ...
                ];
        otherwise
            throw(MException('', ['Tool name ' toolName ' is not valid']))
    end
else
    throw(MException('', ['Cost term type ' costTermType ...
        ' is not valid, must be continuous or discrete']))
end
end

function costTermCalculations = getCostTermCalculations(costTermType)

costTermCalculations.generalized_coordinate_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingCoordinateIntegrand( ...
    costTerm, ...
    auxdata, ...
    values.time, ...
    values.positions, ...
    costTerm.coordinate ...
    );

costTermCalculations.generalized_speed_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingSpeedIntegrand( ...
    costTerm, ...
    auxdata, ...
    values.time, ...
    values.velocities, ...
    costTerm.coordinate ...
    );

costTermCalculations.marker_position_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingMarkerPosition( ...
    costTerm, ...
    values.time, ...
    modeledValues.markerPositions, ...
    auxdata ...
    );

costTermCalculations.controller_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingControllerIntegrand( ...
    costTerm, ...
    auxdata, ...
    values, ...
    values.time, ...
    costTerm.controller ...
    );

costTermCalculations.joint_jerk_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingJointJerkIntegrand( ...
    values.controlJerks, ...
    values.time, ...
    auxdata, ...
    costTerm ...
    );

costTermCalculations.metabolic_cost_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingMetabolicCost( ...
    costTerm, ...
    values, ...
    values.time, ...
    modeledValues, ...
    auxdata);

costTermCalculations.inverse_dynamics_load_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingInverseDynamicLoadsIntegrand( ...
    costTerm, ...
    auxdata, ...
    values.time, ...
    modeledValues.inverseDynamicsMoments, ...
    costTerm.load ...
    );

costTermCalculations.inverse_dynamics_load_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingInverseDynamicLoadsIntegrand( ...
    costTerm, ...
    auxdata, ...
    values.time, ...
    modeledValues.inverseDynamicsMoments, ...
    costTerm.load ...
    );
    
costTermCalculations.kinetic_inconsistency_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingKineticInconsistencyIntegrand( ...
    costTerm, ...
    auxdata, ...
    values.time, ...
    modeledValues, ...
    values.torqueControls, ...
    costTerm.load ...
    );

costTermCalculations.external_force_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingExternalForcesIntegrand( ...
    costTerm, ...
    auxdata, ...
    modeledValues.groundReactionsLab.forces, ...
    values.time, ...
    costTerm.force);

costTermCalculations.external_moment_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingExternalMomentsIntegrand( ...
    costTerm, ...
    auxdata, ...
    modeledValues.groundReactionsLab.moments, ...
    values.time, ...
    costTerm.moment);

costTermCalculations.muscle_activation_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingMuscleActivationIntegrand( ...
    costTerm, ...
    modeledValues.muscleActivations, ...
    values.time, ...
    auxdata, ...
    costTerm.muscle);

costTermCalculations.propulsive_force_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingPropulsiveForceIntegrand( ...
    modeledValues, ...
    values.time, ...
    auxdata, ...
    costTerm);

costTermCalculations.propulsive_force_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingPropulsiveForceIntegrand( ...
    modeledValues, ...
    values.time, ...
    auxdata, ...
    costTerm);

costTermCalculations.breaking_force_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingBreakingForceIntegrand( ...
    modeledValues, ...
    values.time, ...
    auxdata, ...
    costTerm);

costTermCalculations.breaking_force_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingBreakingForceIntegrand( ...
    modeledValues, ...
    values.time, ...
    auxdata, ...
    costTerm);

costTermCalculations.step_length_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingStepLengthIntegrand( ...
    values.time, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.step_length_asymmetry_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcStepLengthAsymmetryIntegrand( ...
    values.time, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.single_support_time_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingSingleSupportTimeIntegrand( ...
    values.time, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.single_support_time_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcGoalSingleSupportTimeIntegrand( ...
    values.time, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.step_time_asymmetry_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcStepTimeAsymmetryIntegrand( ...
    values, ...
    values.time, ...
    modeledValues, ...
    auxdata, ...
    costTerm);

costTermCalculations.joint_power_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingJointPowerIntegrand( ...
    costTerm, ...
    values.velocities, ...
    values.time, ...
    modeledValues.inverseDynamicsMoments, ...
    auxdata, ...
    costTerm.load ...
    );

costTermCalculations.joint_energy_generation_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcJointEnergyGenerationGoalIntegrand( ...
    costTerm, ...
    values.velocities, ...
    values.time, ...
    modeledValues.inverseDynamicsMoments, ...
    auxdata, ...
    costTerm.load ...
    );

costTermCalculations.joint_energy_absorption_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcJointEnergyAbsorptionGoalIntegrand( ...
    costTerm, ...
    values.velocities, ...
    values.time, ...
    modeledValues.inverseDynamicsMoments, ...
    auxdata, ...
    costTerm.load ...
    );

costTermCalculations.propulsive_impulse_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcJointEnergyAbsorptionGoalIntegrand( ...
    modeledValues, ...
    values.time, ...
    auxdata, ...
    costTerm ...
    );

costTermCalculations.braking_impulse_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcJointEnergyAbsorptionGoalIntegrand( ...
    modeledValues, ...
    values.time, ...
    auxdata, ...
    costTerm ...
    );

costTermCalculations.trailing_limb_angle_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingTrailingLimbAngleIntegrand( ...
    values, ...
    values.time, ...
    modeledValues, ...
    auxdata, ...
    costTerm ...
    );

costTermCalculations.trailing_limb_angle_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingTrailingLimbAngleIntegrand( ...
    values, ...
    values.time, ...
    modeledValues, ...
    auxdata, ...
    costTerm ...
    );

costTermCalculations.muscle_activation_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingMuscleActivationIntegrand( ...
    costTerm, ...
    values.time, ...
    modeledValues.muscleActivations, ...
    auxdata, ...
    costTerm.muscle ...
    );

costTermCalculations.muscle_activation_maximization = @(values, modeledValues, auxdata, costTerm) ...
    calcMaximizingMuscleActivationIntegrand( ...
    costTerm, ...
    values.time, ...
    modeledValues.muscleActivations, ...
    auxdata, ...
    costTerm.muscle ...
    );

costTermCalculations.center_mass_velocity_x_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingMassCenterVelocityXIntegrand( ...
    costTerm, ...
    values, ...
    values.time, ...
    auxdata);

costTermCalculations.center_mass_velocity_y_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingMassCenterVelocityYIntegrand( ...
    costTerm, ...
    values, ...
    values.time, ...
    auxdata);

costTermCalculations.center_mass_velocity_z_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingMassCenterVelocityZIntegrand( ...
    costTerm, ...
    values, ...
    values.time, ...
    auxdata);

costTermCalculations.kinematic_symmetry = @(values, modeledValues, auxdata, costTerm) ...
    calcKinematicSymmetryIntegrand( ...
    values.positions, ...
    values.time, ...
    auxdata, ...
    costTerm);

costTermCalculations.walking_speed_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcGoalWalkingSpeedIntegrand( ...
    modeledValues, ...
    values, ...
    values.time, ...
    auxdata, ...
    costTerm);

costTermCalculations.external_torque_control_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingExternalTorqueControl( ...
    costTerm, ...
    values.externalTorqueControls, ...
    values.time, ...
    auxdata, ...
    costTerm.coordinate);

costTermCalculations.angular_momentum_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingAngularMomentumIntegrand( ...
    modeledValues, ...
    values.time, ...
    costTerm);

costTermCalculations.synergy_vector_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingSynergyVectorsDiscrete( ...
    values.synergyWeights, ...
    auxdata, ...
    costTerm);

costTermCalculations.belt_speed_goal = @(values, modeledValues, auxdata, costTerm) ...
    calcGoalBeltSpeedDiscrete( ...
    values, ...
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
