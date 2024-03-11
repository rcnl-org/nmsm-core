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

function inputs = makeOptimalControlBounds(inputs)
inputs = makeStateBounds(inputs);
inputs = makeControlBounds(inputs);
end

function inputs = makeStateBounds(inputs)
if isfield(inputs, "finalTimeRange")
    inputs.maxTime = inputs.finalTimeRange(2);
else
    inputs.maxTime = max(inputs.experimentalTime);
end
inputs.minTime = min(inputs.experimentalTime);

stateJointAngles = subsetDataByCoordinates( ...
    inputs.experimentalJointAngles, ...
    inputs.coordinateNames, ...
    inputs.statesCoordinateNames);
stateJointVelocities = subsetDataByCoordinates( ...
    inputs.experimentalJointVelocities, ...
    inputs.coordinateNames, ...
    inputs.statesCoordinateNames);
% stateJointAccelerations = subsetDataByCoordinates( ...
%     inputs.experimentalJointAccelerations, ...
%     inputs.coordinateNames, ...
%     inputs.statesCoordinateNames);

maxStatePositions = max(stateJointAngles) + ...
    inputs.jointPositionsMultiple * range(stateJointAngles);
minStatePositions = min(stateJointAngles) - ...
    inputs.jointPositionsMultiple * range(stateJointAngles);
maxStateVelocities = max(stateJointVelocities) + ...
    inputs.jointVelocitiesMultiple * range(stateJointVelocities);
minStateVelocities = min(stateJointVelocities) - ...
    inputs.jointVelocitiesMultiple * range(stateJointVelocities);

inputs.maxState = [ ...
    maxStatePositions, ...
    maxStateVelocities, ...
    % maxStateAccelerations, ...
    ];
inputs.minState = [ ...
    minStatePositions, ...
    minStateVelocities, ...
    % minStateAccelerations, ...
    ];
end

function inputs = makeControlBounds(inputs)

stateJointAccelerations = subsetDataByCoordinates( ...
    inputs.experimentalJointAccelerations, ...
    inputs.coordinateNames, ...
    inputs.statesCoordinateNames);

inputs.maxControl = max(stateJointAccelerations) + ...
    inputs.jointAccelerationsMultiple * range(stateJointAccelerations);
inputs.minControl = min(stateJointAccelerations) - ...
    inputs.jointAccelerationsMultiple * range(stateJointAccelerations);

if strcmp(inputs.controllerType, 'synergy')
    maxControlSynergyActivations = inputs.maxControlSynergyActivations * ...
        ones(1, inputs.numSynergies);
    inputs.maxControl = [inputs.maxControl maxControlSynergyActivations];
    inputs.minControl = [inputs.minControl zeros(1, inputs.numSynergies)];

    if inputs.optimizeSynergyVectors
        numParameters = 0;
        for i = 1 : length(inputs.synergyGroups)
            numParameters = numParameters + ...
                inputs.synergyGroups{i}.numSynergies * ...
                length(inputs.synergyGroups{i}.muscleNames);
        end
        inputs.maxParameter = ones(1, numParameters);
        inputs.minParameter = zeros(1, numParameters);
    end
end
if strcmp(inputs.toolName, "DesignOptimization")
    if ~isfield(inputs, "maxParameter")
        inputs.maxParameter = [];
        inputs.minParameter = [];
    end
    for i = 1:length(inputs.userDefinedVariables)
        inputs.maxParameter = [inputs.maxParameter ...
            inputs.userDefinedVariables{i}.upper_bounds];
        inputs.minParameter = [inputs.minParameter ...
            inputs.userDefinedVariables{i}.lower_bounds];
    end
end
if isfield(inputs, "torqueControllerCoordinateNames")
    maxTorqueControls = [];
    minTorqueControls = [];
    for i = 1:length(inputs.torqueControllerCoordinateNames)
        indx = find(strcmp(convertCharsToStrings( ...
            inputs.inverseDynamicsMomentLabels), ...
            strcat(inputs.torqueControllerCoordinateNames(i), '_moment')));
        if isempty(indx)
            indx = find(strcmp(convertCharsToStrings( ...
                inputs.inverseDynamicsMomentLabels), ...
                strcat(inputs.torqueControllerCoordinateNames(i), '_force')));
        end
        maxTorqueControls(i) = max(inputs.experimentalJointMoments(:, ...
            indx)) + inputs.maxTorqueControlsMultiple * ...
            range(inputs.experimentalJointMoments(:, indx));
        minTorqueControls(i) = min(inputs.experimentalJointMoments(:, ...
            indx)) - inputs.maxTorqueControlsMultiple * ...
            range(inputs.experimentalJointMoments(:, indx));
    end
    inputs.maxControl = [inputs.maxControl maxTorqueControls];
    inputs.minControl = [inputs.minControl minTorqueControls];
end
end
