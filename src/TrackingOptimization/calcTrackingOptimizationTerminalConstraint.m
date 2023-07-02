% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the terminal constraint for tracking
% optimization
%
% (struct, struct, struct) -> (Array of number)
% Returns terminal constraint

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

function event = calcTrackingOptimizationTerminalConstraint(inputs, params)

inputs.phase.state = [inputs.phase.initialstate; inputs.phase.finalstate];
inputs.phase.time = [inputs.phase.initialtime; inputs.phase.finaltime];
inputs.phase.control = ones(size(inputs.phase.time,1),length(params.minControl));
if inputs.auxdata.optimizeSynergyVectors
    inputs.phase.parameter = inputs.parameter;
end
values = getTrackingOptimizationValueStruct(inputs.phase, params);
modeledValues = calcTorqueBasedModeledValues(values, params);

event = [];
for i = 1:length(params.terminal)
    constraintTerm = params.terminal{i};
    if constraintTerm.isEnabled
        switch constraintTerm.type
            case "state_position_periodicity"
                event = cat(2, event, ...
                    calcStatePositionPeriodicity(values.statePositions, ...
                    params.coordinateNames, ...
                    constraintTerm.coordinate));
            case "state_velocity_periodicity"
                event = cat(2, event, ...
                    calcStateVelocityPeriodicity(values.stateVelocities, ...
                    params.coordinateNames, ...
                    constraintTerm.coordinate));
            case "root_segment_residual_load_periodicity"
                event = cat(2, event, ...
                    calcRootSegmentResidualsPeriodicity(... 
                    modeledValues.inverseDynamicMoments, ...
                    params.inverseDynamicMomentLabels, ...
                    constraintTerm.load));    
            case "external_force_tracking_periodicity"
                event = cat(2, event, ...
                    calcExternalForcesPeriodicity(... 
                    modeledValues.groundReactionsLab.forces, ...
                    params.contactSurfaces, ...
                    constraintTerm.force));  
            case "external_moment_tracking_periodicity"
                event = cat(2, event, ...
                    calcExternalMomentsPeriodicity(... 
                    modeledValues.groundReactionsLab.moments, ...
                    params.contactSurfaces, ...
                    constraintTerm.moment));  
            case "synergy_weight_sum"
                event = cat(2, event, ...
                    calcSynergyWeightsSum(... 
                    values.synergyWeights, ...
                    params.synergyGroups, ...
                    constraintTerm.synergy_group)); 
            otherwise
                throw(MException('', ['Constraint term type ' ...
                    constraintTerm.type ' does not exist for this tool.']))    
        end
    end
end
end