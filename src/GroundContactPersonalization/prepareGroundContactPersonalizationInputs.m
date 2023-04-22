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

for surface = 1:length(inputs.surfaces)
    inputs.surfaces{surface} = prepareInputsForFoot( ...
        inputs.surfaces{surface}, inputs, meanRightFootMarkerLocations, ...
        surface);
end
inputs.numSpringMarkers = confirmNumSpringMarkers(inputs.surfaces);

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
function surface = prepareInputsForFoot(surface, inputs, ...
    meanMarkerLocations, surfaceNumber)
surface.toesJointName = char(Model(inputs.bodyModel ...
    ).getCoordinateSet().get(surface.toesCoordinateName).getJoint( ...
    ).getName());
[surface.hindfootBodyName, surface.toesBodyName] = ...
    getJointBodyNames(Model(inputs.bodyModel), surface.toesJointName);
surface.coordinatesOfInterest = findGCPFreeCoordinates(...
    Model(inputs.bodyModel), string(surface.toesBodyName));

[footPosition, markerPositions] = ...
    makeFootKinematics(inputs.bodyModel, ...
    inputs.motionFileName, surface.coordinatesOfInterest, ...
    surface.hindfootBodyName, surface.toesCoordinateName, ...
    surface.markerNames, surface.time(1), surface.time(end), ...
    surface.isLeftFoot);

% Use a user-defined cutoff frequency to determine the number of B-spline
% nodes needed to represent kinematics. 
surface.splineNodes = splFitWithCutoff(surface.time, footPosition, ... 
    inputs.kinematicsFilterCutoff, 4, surfaceNumber);
disp("Spline nodes for foot " + task + ": " + surface.splineNodes)
footVelocity = calcBSplineDerivative(surface.time, footPosition, ...
    4, surface.splineNodes);
markerNamesFields = fieldnames(surface.markerNames);
for i=1:length(markerNamesFields)
markerVelocities.(markerNamesFields{i}) = ...
    calcBSplineDerivative(surface.time, markerPositions.(...
    markerNamesFields{i}), 4, surface.splineNodes);
end

taskFootModel = makeFootModel(Model(inputs.bodyModel), ...
    surface.toesJointName, surface.isLeftFoot);
taskFootModel = addSpringsToModel(taskFootModel, surface.markerNames, ...
    inputs.gridWidth, inputs.gridHeight, ...
    surface.hindfootBodyName, surface.toesBodyName, surface.toesJointName, ...
    surface.isLeftFoot, meanMarkerLocations); 
surface.model = "footModel_" + surfaceNumber + ".osim";
taskFootModel.print(surface.model);
surface.numSpringMarkers = findNumSpringMarkers(surface.model);

surface.experimentalMarkerPositions = markerPositions;
surface.experimentalMarkerVelocities = markerVelocities;
surface.experimentalJointPositions = footPosition;
surface.experimentalJointVelocities = footVelocity;
surface.midfootSuperiorPosition = markerPositions.midfootSuperior;

surface.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
    surface.time, surface.experimentalGroundReactionForces, 2, ...
    surface.splineNodes);
surface.jointKinematicsBSplines = makeJointKinematicsBSplines(...
    surface.time, 4, surface.splineNodes);
surface.bSplineCoefficients = ones(surface.splineNodes, 7);
end

% (struct) -> (struct)
% Determines average foot marker locations to ensure the model for each
% foot includes the same number of spring markers at the same relative
% positions. Left foot marker Z positions are negated to be comparable. 
function meanRightFootMarkerLocations = getMeanFootMarkerLocations(inputs)
bodyModel = Model(inputs.bodyModel);
for surface = 1:length(inputs.surfaces)
    footMarkerLocations(surface) = findMarkerPositions(bodyModel, ...
        inputs.surfaces{surface}.markerNames);
    if inputs.surfaces{surface}.isLeftFoot
        for marker = 1:length(fieldnames(footMarkerLocations(surface)))
            fieldNames = fieldnames(footMarkerLocations(surface));
            currentMarker = footMarkerLocations(surface).(fieldNames{marker});
            currentMarker(2) = -1 * currentMarker(2);
            footMarkerLocations(surface).(fieldNames{marker}) = currentMarker;
        end
    end
end
meanRightFootMarkerLocations = footMarkerLocations(1);
for marker = 1:length(fieldnames(meanRightFootMarkerLocations))
    fieldNames = fieldnames(meanRightFootMarkerLocations);
    meanRightFootMarkerLocations.(fieldNames{marker}) = [0 0];
end
for surface = 1:length(inputs.surfaces)
    for marker = 1:length(fieldnames(footMarkerLocations(surface)))
        fieldNames = fieldnames(footMarkerLocations(surface));
        meanRightFootMarkerLocations.(fieldNames{marker}) = ...
            meanRightFootMarkerLocations.(fieldNames{marker}) + ...
            footMarkerLocations(surface).(fieldNames{marker});
    end
end
for marker = 1:length(fieldnames(meanRightFootMarkerLocations))
    fieldNames = fieldnames(meanRightFootMarkerLocations);
    meanRightFootMarkerLocations.(fieldNames{marker}) = ...
        meanRightFootMarkerLocations.(fieldNames{marker}) ./ ...
        length(inputs.surfaces);
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
