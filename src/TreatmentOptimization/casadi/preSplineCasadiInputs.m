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
% Author(s): Spencer Williams                                             %
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

function inputs = preSplineCasadiInputs(inputs)
inputs.collocationTimeBound = scaleToBounds( ...
    inputs.collocationTimeOriginal, inputs.maxTime, inputs.minTime);
time = inputs.collocationTimeOriginal;

inputs.splinedJointAngles = evaluateGcvSplines( ...
    inputs.splineJointAngles, inputs.coordinateNames, time, 0);
inputs.splinedJointSpeeds = evaluateGcvSplines( ...
    inputs.splineJointAngles, inputs.coordinateNames, time, 1);
inputs.splinedJointAccelerations = evaluateGcvSplines( ...
    inputs.splineJointAngles, inputs.coordinateNames, time, 2);
inputs.splinedJointMoments = evaluateGcvSplines( ...
    inputs.splineJointMoments, inputs.inverseDynamicsMomentLabels, time);
if inputs.controllerTypes(2) && ...
        isfield(inputs, 'splineSynergyActivations')
    inputs.splinedSynergyActivations = evaluateGcvSplines( ...
        inputs.splineSynergyActivations, ...
        inputs.synergyLabels, time, 0);
end
if inputs.controllerTypes(3) && ...
        isfield(inputs, 'splineMuscleControls')
    inputs.splinedMuscleControls = evaluateGcvSplines( ...
        inputs.splineMuscleControls, ...
        inputs.individualMuscleNames, time, 0);
end
if any(inputs.controllerTypes(2:3)) && ...
        isfield(inputs, 'splineMuscleActivations')
    inputs.splinedMuscleActivations = evaluateGcvSplines( ...
        inputs.splineMuscleActivations, inputs.muscleLabels, time, 0);
end
if isfield(inputs, 'torqueControllerCoordinateNames') && ...
        ~isempty(inputs.torqueControllerCoordinateNames)
    if isfield(inputs, "splineTorqueControls")
        inputs.splinedTorqueControls = evaluateGcvSplines( ...
            inputs.splineTorqueControls, inputs.torqueLabels, time, 0);
    end
end
if isfield(inputs, "splineMarkerPositions")
    for i = 1:length(inputs.splineMarkerPositions)
        inputs.splinedMarkerPositions{i} = evaluateGcvSplines( ...
            inputs.splineMarkerPositions{i}, 0:2, time, 0);
    end
end
if isfield(inputs, "splineMarkerVelocities")
    for i = 1:length(inputs.splineMarkerVelocities)
        inputs.splinedMarkerVelocities{i} = evaluateGcvSplines( ...
            inputs.splineMarkerVelocities{i}, 0:2, time, 0);
    end
end
if isfield(inputs, 'splineBodyOrientations')
    inputs.splinedBodyOrientations = evaluateGcvSplines( ...
        inputs.splineBodyOrientations, ...
        inputs.splineBodyOrientationsLabels, time, 0);
end
if isfield(inputs, 'splineCenterOfPressure')
    for i = 1:length(inputs.contactSurfaces)
        inputs.splinedCenterOfPressure{i} = evaluateGcvSplines( ...
            inputs.splineCenterOfPressure{i}, 0:1, time, 0);
    end
end
for i = 1:length(inputs.contactSurfaces)
    inputs.splinedGroundReactionForces{i} = evaluateGcvSplines( ...
        inputs.splineExperimentalGroundReactionForces{i}, 0:2, time, 0);
    inputs.splinedGroundReactionMoments{i} = evaluateGcvSplines( ...
        inputs.splineExperimentalGroundReactionMoments{i}, 0:2, time, 0);
end
end
