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

stateJointAngles = subsetDataByCoordinates( ...
    inputs.experimentalJointAngles, ...
    inputs.coordinateNames, ...
    inputs.statesCoordinateNames);
stateJointVelocities = subsetDataByCoordinates( ...
    inputs.experimentalJointVelocities, ...
    inputs.coordinateNames, ...
    inputs.statesCoordinateNames);

minRange = max(inputs.jointPositionsMultiple * range(stateJointAngles), ...
    inputs.jointPositionsMinRange);
maxStatePositions = max(stateJointAngles) + minRange;
minStatePositions = min(stateJointAngles) - minRange;
minRange = max(inputs.jointVelocitiesMultiple * ...
    range(stateJointVelocities), inputs.jointVelocitiesMinRange);
maxStateVelocities = max(stateJointVelocities) + minRange;
minStateVelocities = min(stateJointVelocities) - minRange;

inputs.maxState = [ ...
    maxStatePositions, ...
    maxStateVelocities, ...
    ];
inputs.minState = [ ...
    minStatePositions, ...
    minStateVelocities, ...
    ];
end

function inputs = makeControlBounds(inputs)

stateJointAccelerations = subsetDataByCoordinates( ...
    inputs.experimentalJointAccelerations, ...
    inputs.coordinateNames, ...
    inputs.statesCoordinateNames);

minRange = max(inputs.jointAccelerationsMultiple * ...
    range(stateJointAccelerations), inputs.jointAccelerationsMinRange);
inputs.maxControl = max(stateJointAccelerations) + minRange;
inputs.minControl = min(stateJointAccelerations) - minRange;

if inputs.controllerTypes(3)
    inputs.maxControl = [inputs.maxControl ones(1, ...
        inputs.numIndividualMuscles)];
    inputs.minControl = [inputs.minControl zeros(1, ...
        inputs.numIndividualMuscles)];
end
if inputs.controllerTypes(2)
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
        inputs.maxParameter = ones(1, numParameters) * ...
            inputs.synergyNormalizationValue;
        inputs.minParameter = zeros(1, numParameters);
    end
end
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
        minRange = max(inputs.maxTorqueControlsMultiple * ...
            range(inputs.experimentalJointMoments(:, indx)), ...
            inputs.maxTorqueControlsMinRange);
        maxTorqueControls(i) = max(inputs.experimentalJointMoments(:, ...
            indx)) + minRange;
        minTorqueControls(i) = min(inputs.experimentalJointMoments(:, ...
            indx)) - minRange;
    end
    inputs.maxControl = [inputs.maxControl maxTorqueControls];
    inputs.minControl = [inputs.minControl minTorqueControls];
end
end
