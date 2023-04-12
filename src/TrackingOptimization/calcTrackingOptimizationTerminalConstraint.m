% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

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
modeledValues = calcTrackingOptimizationTorqueBasedModeledValues(values, params);

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
            case "external_force_periodicity"
                event = cat(2, event, ...
                    calcExternalForcesPeriodicity(... 
                    modeledValues.groundReactionsLab.forces, ...
                    params.contactSurfaces, ...
                    constraintTerm.force));  
            case "external_moment_periodicity"
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
        end
    end
end
end
function statePositionPeriodicity = calcStatePositionPeriodicity( ...
    statePositions, coordinateNames, coordinateName)
indx = find(strcmp(convertCharsToStrings(coordinateNames), ...
    coordinateName));
statePositionPeriodicity = diff(statePositions(:, indx));
end
function stateVelocityPeriodicity = calcStateVelocityPeriodicity( ...
    stateVelocities, coordinateNames, coordinateName)
indx = find(strcmp(convertCharsToStrings(coordinateNames), ...
    coordinateName));
stateVelocityPeriodicity = diff(stateVelocities(:, indx));
end
function rootSegmentResidualsPeriodicity = calcRootSegmentResidualsPeriodicity( ...
    inverseDynamicMoments, inverseDynamicMomentLabels, loadNames)
indx = find(strcmp(convertCharsToStrings(inverseDynamicMomentLabels), ...
    loadNames));
rootSegmentResidualsPeriodicity = diff(inverseDynamicMoments(:, indx));
end
function externalForcesPeriodicity = calcExternalForcesPeriodicity( ...
    groundReactionForces, contactSurfaces, forceName)
for i = 1:length(contactSurfaces)
    indx = find(strcmp(convertCharsToStrings( ...
        contactSurfaces{i}.forceColumns), forceName));
    if ~isempty(indx)
        externalForcesPeriodicity = diff(groundReactionForces{i}(:, indx));
    end
end
end
function externalMomentsPeriodicity = calcExternalMomentsPeriodicity( ...
    groundReactionMoments, contactSurfaces, momentName)
for i = 1:length(contactSurfaces)
    indx = find(strcmp(convertCharsToStrings( ...
        contactSurfaces{i}.momentColumns), momentName));
    if ~isempty(indx)
        externalMomentsPeriodicity = diff(groundReactionMoments{i}(:, indx));
    end
end
end
function synergyWeightsSum = calcSynergyWeightsSum(synergyWeights, ...
    synergyGroups, synergyGroupName)

numSynergiesIndex(1) = 0;
numMusclesIndex(1) = 0;
for i = 1 : length(synergyGroups)
    temp = find(strcmp(convertCharsToStrings(synergyGroups{i}.muscleGroupName), ...
        synergyGroupName));
    if ~isempty(temp)
        indx = i;
    end
end
for j = 1 : indx
    numSynergiesIndex(end+1) = numSynergiesIndex(end) + ...
        synergyGroups{j}.numSynergies;
    numMusclesIndex(end+1) = numMusclesIndex(end) + ...
        size(synergyGroups{j}.muscleNames, 2);
end
synergyWeightsSum = sum(synergyWeights(1 + numSynergiesIndex(end-1): ...
    numSynergiesIndex(end), 1 + numMusclesIndex(end-1) : ...
    numMusclesIndex(end)), 2)';
end