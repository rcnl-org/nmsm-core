% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns all of the constraint term calculation methods
% Tools use this function for the discrete and continuous constraint
% calculations.
%
% inputs:
% constraintTermType - one of ["path", "terminal"]
% controllerType - one of ["torque", "synergy"]
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

function [constraintTermCalculations, allowedTypes] = ...
    generateConstraintTermStruct(constraintTermType, controllerType, ...
    toolName)
allowedTypes = getAllowedTypes(constraintTermType, controllerType, ...
    toolName);
constraintTermCalculations = ...
    getConstraintTermCalculations();
end

function allowedTypes = getAllowedTypes(constraintTermType, ...
    controllerType, toolName)
allowedTypes = [];
if strcmp(controllerType, "torque")
    switch toolName
        case "TrackingOptimization"
            if strcmp(constraintTermType, "path")
                allowedTypes = [ ...
                    "root_segment_residual_load", ...
                    "torque_model_moment_consistency", ...
                    "kinetic_consistency", ...
                    ];
            end
            if strcmp(constraintTermType, "terminal")
                allowedTypes = [ ...
                    "state_position_periodicity", ...
                    "state_velocity_periodicity", ...
                    "root_segment_residual_load_periodicity", ...
                    "external_force_periodicity", ...
                    "external_moment_periodicity", ...
                    ];
            end
        case "VerificationOptimization"
            if strcmp(constraintTermType, "path")
                allowedTypes = [ ...
                    "root_segment_residual_load", ...
                    "torque_model_moment_consistency", ...
                    "kinetic_consistency", ...
                    ];
            end
            if strcmp(constraintTermType, "terminal")
                allowedTypes = [ ...
                    "state_position_periodicity", ...
                    "state_velocity_periodicity", ...
                    "root_segment_residual_load_periodicity", ...
                    "external_force_periodicity", ...
                    "external_moment_periodicity", ...
                    ];
            end
        case "DesignOptimization"
            if strcmp(constraintTermType, "path")
                allowedTypes = [ ...
                    "root_segment_residual_load", ...
                    "torque_model_moment_consistency", ...
                    "kinetic_consistency", ...
                    "limit_normalized_fiber_length", ...
                    ];
            end
            if strcmp(constraintTermType, "terminal")
                allowedTypes = [ ...
                    "state_position_periodicity", ...
                    "state_velocity_periodicity", ...
                    "root_segment_residual_load_periodicity", ...
                    "external_force_periodicity", ...
                    "external_moment_periodicity", ...
                    "initial_state_position_tracking", ...
                    "final_state_position", ...
                    "final_state_velocity", ...
                    "final_point_position", ...
                    "final_point_velocity", ...
                    ];
            end
    end
end
if strcmp(controllerType, "synergy")
    switch toolName
        case "TrackingOptimization"
            if strcmp(constraintTermType, "path")
                allowedTypes = [ ...
                    "root_segment_residual_load", ...
                    "muscle_model_moment_consistency", ...
                    "kinetic_consistency", ...
                    ];
            end
            if strcmp(constraintTermType, "terminal")
                allowedTypes = [ ...
                    "state_position_periodicity", ...
                    "state_velocity_periodicity", ...
                    "root_segment_residual_load_periodicity", ...
                    "external_force_periodicity", ...
                    "external_moment_periodicity", ...
                    "synergy_weight_sum", ...
                    "synergy_weight_magnitude", ...
                    ];
            end
        case "VerificationOptimization"
            if strcmp(constraintTermType, "path")
                allowedTypes = [ ...
                    "root_segment_residual_load", ...
                    "muscle_model_moment_consistency", ...
                    "kinetic_consistency", ...
                    ];
            end
            if strcmp(constraintTermType, "terminal")
                allowedTypes = [ ...
                    "state_position_periodicity", ...
                    "state_velocity_periodicity", ...
                    "root_segment_residual_load_periodicity", ...
                    "external_force_periodicity", ...
                    "external_moment_periodicity", ...
                    ];
            end
        case "DesignOptimization"
            if strcmp(constraintTermType, "path")
                allowedTypes = [ ...
                    "root_segment_residual_load", ...
                    "muscle_model_moment_consistency", ...
                    "kinetic_consistency", ...
                    "limit_muscle_activation", ...
                    "limit_normalized_fiber_length", ...
                    "external_control_muscle_moment_consistency", ...
                    ];
            end
            if strcmp(constraintTermType, "terminal")
                allowedTypes = [ ...
                    "state_position_periodicity", ...
                    "state_velocity_periodicity", ...
                    "root_segment_residual_load_periodicity", ...
                    "external_force_periodicity", ...
                    "external_moment_periodicity", ...
                    "synergy_weight_sum", ...
                    "synergy_weight_magnitude", ...
                    "initial_state_position_tracking", ...
                    "final_state_position", ...
                    "final_state_velocity", ...
                    "final_point_position", ...
                    "final_point_velocity", ...
                    ];
            end
    end
end
end

function constraintTermCalculations = getConstraintTermCalculations()

constraintTermCalculations.root_segment_residual_load = @(values, modeledValues, auxdata, constraintTerm) ...
    calcRootSegmentResidualsPathConstraints( ...
    constraintTerm.load, ...
    auxdata.inverseDynamicsMomentLabels, ...
    modeledValues.inverseDynamicsMoments ...
    );

constraintTermCalculations.muscle_model_moment_consistency = @(values, modeledValues, auxdata, constraintTerm) ...
    calcMuscleActuatedMomentsPathConstraints( ...
    auxdata, ...
    modeledValues, ...
    constraintTerm.load ...
    );

constraintTermCalculations.torque_model_moment_consistency = @(values, modeledValues, auxdata, constraintTerm) ...
    calcTorqueActuatedMomentsPathConstraints( ...
    auxdata, ...
    modeledValues, ...
    values.torqueControls, ...
    constraintTerm.load ...
    );

constraintTermCalculations.kinetic_consistency = @(values, modeledValues, auxdata, constraintTerm) ...
    calcKineticPathConstraint( ...
    auxdata, ...
    modeledValues, ...
    values.torqueControls, ...
    constraintTerm.load ...
    );

constraintTermCalculations.limit_muscle_activation = @(values, modeledValues, auxdata, constraintTerm) ...
    calcMuscleActivationsPathConstraint( ...
    auxdata, ...
    modeledValues, ...
    constraintTerm.muscle);

constraintTermCalculations.limit_normalized_fiber_length = @(values, modeledValues, auxdata, constraintTerm) ...
    calcNormalizedFiberLengthPathConstraint( ...
    auxdata, ...
    modeledValues, ...
    constraintTerm.muscle ...
    );

constraintTermCalculations.external_control_muscle_moment_consistency = @(values, modeledValues, auxdata, constraintTerm) ...
    calcMuscleActuatedMomentsWithExternalAidPathConstraints( ...
    auxdata, ...
    modeledValues, ...
    values.externalTorqueControls, ...
    contraintTerm.coordinate ...
    );

constraintTermCalculations.state_position_periodicity = @(values, modeledValues, auxdata, constraintTerm) ...
    calcStatePositionPeriodicity( ...
    values.statePositions, ...
    auxdata.statesCoordinateNames, ...
    constraintTerm.coordinate ...
    );

constraintTermCalculations.state_velocity_periodicity = @(values, modeledValues, auxdata, constraintTerm) ...
    calcStateVelocityPeriodicity( ...
    values.stateVelocities, ...
    auxdata.statesCoordinateNames, ...
    constraintTerm.coordinate ...
    );

constraintTermCalculations.root_segment_residual_load_periodicity = @(values, modeledValues, auxdata, constraintTerm) ...
    calcRootSegmentResidualsPeriodicity(...
    modeledValues.inverseDynamicsMoments, ...
    auxdata.inverseDynamicsMomentLabels, ...
    constraintTerm.load);

constraintTermCalculations.external_force_periodicity = @(values, modeledValues, auxdata, constraintTerm) ...
    calcExternalForcesPeriodicity(...
    modeledValues.groundReactionsLab.forces, ...
    auxdata.contactSurfaces, ...
    constraintTerm.force);

constraintTermCalculations.external_moment_periodicity = @(values, modeledValues, auxdata, constraintTerm) ...
    calcExternalMomentsPeriodicity(...
    modeledValues.groundReactionsLab.moments, ...
    auxdata.contactSurfaces, ...
    constraintTerm.moment);

constraintTermCalculations.initial_state_position_tracking = @(values, modeledValues, auxdata, constraintTerm) ...
    calcInitialStatePosition( ...
    values.statePositions, ...
    auxdata.statesCoordinateNames, ...
    auxdata, ...
    constraintTerm);

constraintTermCalculations.final_state_position = @(values, modeledValues, auxdata, constraintTerm) ...
    calcFinalStatePosition( ...
    values.statePositions, ...
    auxdata.statesCoordinateNames, ...
    constraintTerm);

constraintTermCalculations.final_state_velocity = @(values, modeledValues, auxdata, constraintTerm) ...
    calcFinalStateVelocity(values.stateVelocities, ...
    auxdata.coordinateNames, ...
    constraintTerm);

constraintTermCalculations.final_point_position = @(values, modeledValues, auxdata, constraintTerm) ...
    calcFinalPointPosition(auxdata, values, ...
    constraintTerm);

constraintTermCalculations.final_point_velocity = @(values, modeledValues, auxdata, constraintTerm) ...
    calcFinalPointVelocity(auxdata, values, ...
    constraintTerm);

constraintTermCalculations.synergy_weight_sum = @(values, modeledValues, auxdata, constraintTerm) ...
    calcSynergyWeightsSum(...
    values.synergyWeights, ...
    auxdata.synergyGroups, ...
    constraintTerm.synergy_group);

constraintTermCalculations.synergy_weight_magnitude = @(values, modeledValues, auxdata, constraintTerm) ...
    calcSynergyWeightsMagnitude(...
    values.synergyWeights, ...
    auxdata.synergyGroups, ...
    constraintTerm.synergy_group);

end
