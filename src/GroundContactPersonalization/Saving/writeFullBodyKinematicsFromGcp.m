% This function is part of the NMSM Pipeline, see file for full license.
%
% Saves a ground contact .osimx model and experimental and modeled
% kinematics and ground reactions for each foot.
%
% (struct, struct, string) -> (None)
% Save Ground Contact Personalization kinematics results.

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

function writeFullBodyKinematicsFromGcp(inputs, params, resultsDirectory)
timePoints = inputs.surfaces{1}.time;
for foot = 1:length(inputs.surfaces)
    if any(size(timePoints) ~= size(inputs.surfaces{foot}.time)) || ...
            any(timePoints ~= inputs.surfaces{foot}.time)
        return;
    end
end
for foot = 1:length(inputs.surfaces)
    models.("model_" + foot) = Model(inputs.surfaces{foot}.model);
end
footMarkerNames = string([]);
for foot = 1:length(inputs.surfaces)
    [modeledJointPositions, modeledJointVelocities] = ...
        calcGCPJointKinematics(inputs.surfaces{foot} ...
        .experimentalJointPositions, inputs.surfaces{foot} ...
        .jointKinematicsBSplines, inputs.surfaces{foot}.bSplineCoefficients);
    modeledValues = calcGCPModeledValues(inputs, inputs, ...
        modeledJointPositions, modeledJointVelocities, params, ...
        length(params.tasks), foot, models);

    % footMarkerPositions = zeros(length(timePoints), 9 * 3 * length(inputs.surfaces));
    footMarkerNames(end + 1) = inputs.surfaces{foot}.markerNames.toe;
    footMarkerNames(end + 1) = inputs.surfaces{foot}.markerNames.medial;
    footMarkerNames(end + 1) = inputs.surfaces{foot}.markerNames.lateral;
    footMarkerNames(end + 1) = inputs.surfaces{foot}.markerNames.heel;
    footMarkerNames(end + 1) = inputs.surfaces{foot}.markerNames.midfootSuperior;

    footMarkerData.(footMarkerNames(end - 4)) = modeledValues.markerPositions.toe;
    footMarkerData.(footMarkerNames(end - 3)) = modeledValues.markerPositions.medial;
    footMarkerData.(footMarkerNames(end - 2)) = modeledValues.markerPositions.lateral;
    footMarkerData.(footMarkerNames(end - 1)) = modeledValues.markerPositions.heel;
    footMarkerData.(footMarkerNames(end)) = modeledValues.markerPositions.midfootSuperior;

end

% make kinematics cropped in time
[motionColumnLabels, motionTime, motionData] = ...
    parseMotToComponents(Model(inputs.bodyModel), ...
    org.opensim.modeling.Storage(inputs.motionFileName));
includedFrames = ismember(motionTime, timePoints);
if any(size(timePoints) ~= size(motionTime(includedFrames))) || ...
        any(timePoints ~= motionTime(includedFrames))
    return;
end
writeToSto(motionColumnLabels, timePoints, ...
    motionData(:, includedFrames)', "preGcpMotion.sto");

% write trc file from kinematics
trcFromMotParams.trcFileName = "preGcp.trc";
trcFromMotParams.dataRate = .00001;
TrcFromMot(inputs.bodyModel, "preGcpMotion.sto", trcFromMotParams)

% load trc file
timeSeriesTable = TimeSeriesTableVec3(trcFromMotParams.trcFileName);
columnNames = timeSeriesTable.getColumnLabels();
strings = {};
for i=0:columnNames.size()-1
    strings{end+1} = columnNames.get(i);
end
markerNames = string(strings);

% put foot marker data inside trc file
for i = 1:length(footMarkerNames)
    column = timeSeriesTable.updDependentColumn(footMarkerNames(i));
    for j = 1:length(inputs.surfaces{1}.time)
        temp = footMarkerData.(footMarkerNames(i))(:, j);
        column.set(i-1, org.opensim.modeling.Vec3(temp(1), temp(2), temp(3)));
    end
end

for i = 1:length(timePoints)
    timeSeriesTable.setIndependentValueAtIndex(i - 1, timePoints(i));
end

% save trc file
trcFileName = "postGcp.trc";
trcFileAdapter = org.opensim.modeling.TRCFileAdapter();
trcFileAdapter.write(timeSeriesTable, trcFileName);

import org.opensim.modeling.TimeSeriesTableVec3
import org.opensim.modeling.SetMarkerWeights
import org.opensim.modeling.MarkerWeight
timeSeriesTable = TimeSeriesTableVec3(trcFileName);
strings = {};
columnNames = timeSeriesTable.getColumnLabels();
for i=0:columnNames.size()-1
    strings{end+1} = columnNames.get(i);
end
markerNames = string(strings);
markerWeightSet = SetMarkerWeights();
for i=1:length(markerNames)
    if any(ismember(fieldnames(footMarkerData), markerNames(i)))
        markerWeightSet.cloneAndAppend(MarkerWeight(markerNames(i), 1000.0));
    else
        markerWeightSet.cloneAndAppend(MarkerWeight(markerNames(i), 1.0));
    end
end
try
    markersReference = org.opensim.modeling.MarkersReference(trcFileName, markerWeightSet);
catch
    markersReference = org.opensim.modeling.MarkersReference(trcFileName);
    markersReference.setMarkerWeightSet(markerWeightSet);
end
timeSeriesTable = libpointer;
[model, state] = Model(inputs.bodyModel);
ikSolver = org.opensim.modeling.InverseKinematicsSolver(model, markersReference, ...
    org.opensim.modeling.SimTKArrayCoordinateReference());
ikSolver.setAccuracy(1e-6);

% make new kinematics *run ik solver*

kinematicsReporter = org.opensim.modeling.Kinematics(model);
kinematicsReporter.setInDegrees(false); 
state.setTime(timePoints(1));
ikSolver.assemble(state);
kinematicsReporter.begin(state);
for i = 1:length(timePoints)
    state.setTime(timePoints(i));
    ikSolver.track(state);
    kinematicsReporter.step(state, i);
end
[~,name,ext] = fileparts(inputs.motionFileName);
outfile = strcat("gcp_modeled_", name, ext);
if ~exist(fullfile(resultsDirectory, "IKData"), "dir")
    mkdir(fullfile(resultsDirectory, "IKData"))
end
kinematicsReporter.getPositionStorage().print( ...
    fullfile(resultsDirectory, "IKData", outfile));
[columnNames, time, data] = parseMotToComponents(model, ...
    org.opensim.modeling.Storage(fullfile(resultsDirectory, "IKData", outfile)));
data = lowpassFilter(time, data', 4, 6, 0);
writeToSto(columnNames, timePoints, data, ...
    fullfile(resultsDirectory, "IKData", outfile));
delete postGcp.trc
delete preGcp.trc
delete preGcpMotion.sto
end

