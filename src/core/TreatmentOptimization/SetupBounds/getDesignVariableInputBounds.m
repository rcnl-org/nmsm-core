% This function is part of the NMSM Pipeline, see file for full license.
%
% This functions computes the maximum and minimum values for all design
% variables. The maximum and minimum values for most design variables are
% based on the multiples value selected by the user times the range of data.
% For example, if the angle B has a range of -5 to +5, and state position
% multiple is 1, the maximum value of angle B is 15 and the minimum value
% of angle B is -15. 
%
% (struct) -> (struct)
% Computes max and min design variable bounds

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

function inputs = getDesignVariableInputBounds(inputs)
if isfield(inputs, "finalTimeRange")
    inputs.maxTime = max(inputs.experimentalTime) + inputs.finalTimeRange;
else
    inputs.maxTime = max(inputs.experimentalTime);
end
inputs.minTime = min(inputs.experimentalTime);

maxStatePositions = max(inputs.experimentalJointAngles) + ...
    inputs.statePositionsMultiple * range(inputs.experimentalJointAngles);
minStatePositions = min(inputs.experimentalJointAngles) - ...
    inputs.statePositionsMultiple * range(inputs.experimentalJointAngles);
maxStateVelocities = max(inputs.experimentalJointVelocities) + ...
    inputs.stateVelocitiesMultiple * range(inputs.experimentalJointVelocities);
minStateVelocities = min(inputs.experimentalJointVelocities) - ...
    inputs.stateVelocitiesMultiple * range(inputs.experimentalJointVelocities);
maxStateAccelerations = max(inputs.experimentalJointAccelerations) + ...
    inputs.stateAccelerationsMultiple * range(inputs.experimentalJointAccelerations);
minStateAccelerations = min(inputs.experimentalJointAccelerations) - ...
    inputs.stateAccelerationsMultiple * range(inputs.experimentalJointAccelerations);

inputs.maxState = [maxStatePositions maxStateVelocities maxStateAccelerations];
inputs.minState = [minStatePositions minStateVelocities minStateAccelerations];

maxControlJerks = max(inputs.experimentalJointJerks) + ...
    inputs.controlJerksMultiple * range(inputs.experimentalJointJerks);
minControlJerks = min(inputs.experimentalJointJerks) - ...
    inputs.controlJerksMultiple * range(inputs.experimentalJointJerks);

if strcmp(inputs.controllerType, 'synergy_driven') 
    maxControlSynergyActivations = inputs.maxControlSynergyActivations * ...
        ones(1, inputs.numSynergies);
    inputs.maxControl = [maxControlJerks maxControlSynergyActivations];
    inputs.minControl = [minControlJerks zeros(1, inputs.numSynergies)];
    
    if inputs.optimizeSynergyVectors
    inputs.maxParameter = inputs.maxParameterSynergyWeights * ...
        ones(1, inputs.numSynergyWeights);
    inputs.minParameter = zeros(1, inputs.numSynergyWeights);
    end
elseif strcmp(inputs.controllerType, 'torque_driven') 
    for i = 1:length(inputs.controlTorqueNames)
        indx = find(strcmp(convertCharsToStrings( ...
            inputs.inverseDynamicMomentLabels), ...
            strcat(inputs.controlTorqueNames(i), '_moment')));
        if isempty(indx)
            indx = find(strcmp(convertCharsToStrings( ...
                inputs.inverseDynamicMomentLabels), ...
                strcat(inputs.controlTorqueNames(i), '_force')));
        end
        maxControlTorques(i) = max(inputs.experimentalJointMoments(:, ...
            indx)) + inputs.maxControlTorquesMultiple * ...
            range(inputs.experimentalJointMoments(:, indx));
        minControlTorques(i) = min(inputs.experimentalJointMoments(:, ...
            indx)) - inputs.maxControlTorquesMultiple * ...
            range(inputs.experimentalJointMoments(:, indx));
    end
    inputs.maxControl = [maxControlJerks maxControlTorques];
    inputs.minControl = [minControlJerks minControlTorques];
end

if isfield(inputs, "enableExternalTorqueControl") && ...
        inputs.enableExternalTorqueControl 
    for i = 1:length(inputs.externalControlTorqueNames)
        indx = find(strcmp(convertCharsToStrings( ...
            inputs.inverseDynamicMomentLabels), ...
            strcat(inputs.externalControlTorqueNames(i), '_moment')));
        maxExternalControlTorques(i) = max(inputs.experimentalJointMoments(:, ...
            indx)) + inputs.maxExternalTorqueControls * ...
            range(inputs.experimentalJointMoments(:, indx));
        minExternalControlTorques(i) = min(inputs.experimentalJointMoments(:, ...
            indx)) - inputs.maxExternalTorqueControls * ...
            range(inputs.experimentalJointMoments(:, indx));
    end
    inputs.maxControl = [inputs.maxControl maxExternalControlTorques];
    inputs.minControl = [inputs.minControl minExternalControlTorques];
end
end