% This function is part of the NMSM Pipeline, see file for full license.
%
% Prepare calculated inputs from parsed Ground Contact Personalization 
% inputs. Calculated inputs are inputs not given in input files but derived
% without optimizations, such as B-spline representations of kinematics and
% the isolated foot models. 
%
% (struct) -> (struct)
% Prepare calculated inputs from parsed GCP inputs.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function inputs = prepareGroundContactPersonalizationInputs(inputs)
inputs.gridWidth = 5;
inputs.gridHeight = 15;

% Mean marker locations are used to ensure any included feet have the same 
% number of spring markers. 
meanRightFootMarkerLocations = getMeanFootMarkerLocations(inputs);

for task = 1:length(inputs.tasks)
    inputs.tasks{task} = prepareInputsForFoot(inputs.tasks{task}, ...
        inputs, meanRightFootMarkerLocations, task);
end
inputs.numSpringMarkers = confirmNumSpringMarkers(inputs.tasks);

% Initialize potential design variables from parsed initial values.
inputs.springConstants = inputs.initialSpringConstants * ones(1, ...
    inputs.numSpringMarkers);
inputs.dampingFactor = inputs.initialDampingFactor;
inputs.dynamicFrictionCoefficient = ...
    inputs.initialDynamicFrictionCoefficient;
inputs.viscousFrictionCoefficient = ...
    inputs.initialViscousFrictionCoefficient;
inputs.restingSpringLength = inputs.initialRestingSpringLength;
end

% (struct, struct, struct, double) -> (struct)
% Prepares optimization values specific to a foot.
function task = prepareInputsForFoot(task, inputs, meanMarkerLocations, ...
    taskNumber)
task.toesJointName = char(Model(inputs.bodyModel ...
    ).getCoordinateSet().get(task.toesCoordinateName).getJoint(...
    ).getName());
[task.hindfootBodyName, task.toesBodyName] = ...
    getJointBodyNames(Model(inputs.bodyModel), task.toesJointName);
task.coordinatesOfInterest = findGCPFreeCoordinates(...
    Model(inputs.bodyModel), string(task.toesBodyName));

[footPosition, markerPositions] = ...
    makeFootKinematics(inputs.bodyModel, ...
    inputs.motionFileName, task.coordinatesOfInterest, ...
    task.hindfootBodyName, task.toesCoordinateName, ...
    task.markerNames, task.time(1), task.time(end), task.isLeftFoot);

% Use a user-defined cutoff frequency to determine the number of B-spline
% nodes needed to represent kinematics. 
task.splineNodes = splFitWithCutoff(task.time, footPosition, ... 
    inputs.kinematicsFilterCutoff, 4, taskNumber);

footVelocity = calcBSplineDerivative(task.time, footPosition, ...
    4, task.splineNodes);
markerNamesFields = fieldnames(task.markerNames);
for i=1:length(markerNamesFields)
markerVelocities.(markerNamesFields{i}) = ...
    calcBSplineDerivative(task.time, markerPositions.(...
    markerNamesFields{i}), 4, task.splineNodes);
end

taskFootModel = makeFootModel(Model(inputs.bodyModel), ...
    task.toesJointName);
taskFootModel = addSpringsToModel(taskFootModel, task.markerNames, ...
    inputs.gridWidth, inputs.gridHeight, ...
    task.hindfootBodyName, task.toesBodyName, task.toesJointName, ...
    task.isLeftFoot, meanMarkerLocations); 
task.model = "footModel_" + taskNumber + ".osim";
taskFootModel.print(task.model);
task.numSpringMarkers = findNumSpringMarkers(task.model);

task.experimentalMarkerPositions = markerPositions;
task.experimentalMarkerVelocities = markerVelocities;
task.experimentalJointPositions = footPosition;
task.experimentalJointVelocities = footVelocity;
task.midfootSuperiorPosition = markerPositions.midfootSuperior;

task.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
    task.time, task.experimentalGroundReactionForces, 2, ...
    task.splineNodes);
task.jointKinematicsBSplines = makeJointKinematicsBSplines(...
    task.time, 4, task.splineNodes);
task.bSplineCoefficients = ones(task.splineNodes, 7);
end

% (struct) -> (struct)
% Determines average foot marker locations to ensure the model for each
% foot includes the same number of spring markers at the same relative
% positions. Left foot marker Z positions are negated to be comparable. 
function meanRightFootMarkerLocations = getMeanFootMarkerLocations(inputs)
bodyModel = Model(inputs.bodyModel);
for task = 1:length(inputs.tasks)
    footMarkerLocations(task) = findMarkerPositions(bodyModel, ...
        inputs.tasks{task}.markerNames);
    if inputs.tasks{task}.isLeftFoot
        for marker = 1:length(fieldnames(footMarkerLocations(task)))
            fieldNames = fieldnames(footMarkerLocations(task));
            currentMarker = footMarkerLocations(task).(fieldNames{marker});
            currentMarker(2) = -1 * currentMarker(2);
            footMarkerLocations(task).(fieldNames{marker}) = currentMarker;
        end
    end
end
meanRightFootMarkerLocations = footMarkerLocations(1);
for marker = 1:length(fieldnames(meanRightFootMarkerLocations))
    fieldNames = fieldnames(meanRightFootMarkerLocations);
    meanRightFootMarkerLocations.(fieldNames{marker}) = [0 0];
end
for task = 1:length(inputs.tasks)
    for marker = 1:length(fieldnames(footMarkerLocations(task)))
        fieldNames = fieldnames(footMarkerLocations(task));
        meanRightFootMarkerLocations.(fieldNames{marker}) = ...
            meanRightFootMarkerLocations.(fieldNames{marker}) + ...
            footMarkerLocations(task).(fieldNames{marker});
    end
end
for marker = 1:length(fieldnames(meanRightFootMarkerLocations))
    fieldNames = fieldnames(meanRightFootMarkerLocations);
    meanRightFootMarkerLocations.(fieldNames{marker}) = ...
        meanRightFootMarkerLocations.(fieldNames{marker}) ./ ...
        length(inputs.tasks);
end
end

% (Cell Array) -> (double)
% Confirms that all feet have the same number of spring markers and returns
% the number of spring markers.
function numSpringMarkers = confirmNumSpringMarkers(tasks)
    counts = zeros(1, length(tasks));
    for task = 1:length(tasks)
        counts(task) = tasks{task}.numSpringMarkers;
    end
    if any(counts ~= counts(1))
        throw(MException('', 'Feet have an unequal number of springs'))
    end
    numSpringMarkers = counts(1);
end
