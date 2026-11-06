% This function is part of the NMSM Pipeline, see file for full license.
%
% Reads marker, ground reaction, and EMG data from a .c3d file with
% OpenSim's C3DFileAdapter and returns them as MATLAB arrays in meters.
%
% Markers are returned with three columns (x, y, z) per marker. Ground
% reactions are returned with nine columns per force plate in the order
% force (vx vy vz), point (px py pz), moment (mx my mz), expressed at the
% force plate origin (electrical center), which does not jump around like
% the center of pressure. EMG channels are the analog channels named in
% options.emgChannelNames, or every analog channel not used by a force
% plate when no names are given.
%
% Each returned data type is a struct with fields time (column), labels
% (row of string), data (time x columns), and dataRate (Hz). Data types not
% requested in options are not returned.
%
% (string, struct) -> (struct)
% Extracts markers, ground reactions, and EMG from a .c3d file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function c3dData = extractC3dData(c3dFile, options)
import org.opensim.modeling.C3DFileAdapter
if ~isfile(c3dFile)
    throw(MException("extractC3dData:fileNotFound", ...
        "Cannot find c3d file " + c3dFile))
end
parameters = readC3dParameters(c3dFile);
adapter = C3DFileAdapter();
% 0 = OriginOfForcePlate, i.e. the electrical center
adapter.setLocationForForceExpression(0);
tables = adapter.read(c3dFile);
markerTable = adapter.getMarkersTable(tables);
lengthUnits = getLengthUnits(markerTable, parameters);

c3dData = struct();
if valueOrAlternate(options, "extractMarkers", true)
    c3dData.markers = extractMarkers(markerTable, parameters, lengthUnits);
end
if valueOrAlternate(options, "extractGroundReactions", true)
    c3dData.groundReactions = extractGroundReactions( ...
        adapter.getForcesTable(tables), parameters, lengthUnits);
end
if valueOrAlternate(options, "extractEmg", true)
    c3dData.emg = extractEmg(getAnalogTable(adapter, tables), ...
        parameters, valueOrAlternate(options, "emgChannelNames", ...
        string([])));
end
end

function markers = extractMarkers(table, parameters, lengthUnits)
if table.getNumColumns() == 0
    throw(MException("extractC3dData:noMarkers", ...
        "The c3d file does not contain any markers."))
end
markers.labels = resolveC3dLabels(getLabels(table), parameters, "POINT");
verifyMarkerLabels(markers.labels);
[markers.time, markers.dataRate] = getTime(table);
markers.data = convertLengthUnitsToMeters( ...
    table.flatten().getMatrix().getAsMat(), lengthUnits);
end

function groundReactions = extractGroundReactions(table, parameters, ...
    lengthUnits)
numPlates = double(table.getNumColumns()) / 3;
if numPlates == 0
    throw(MException("extractC3dData:noForcePlates", ...
        "The c3d file does not contain any force plates."))
end
warnIfForcePlatesUncalibrated(parameters);
[groundReactions.time, groundReactions.dataRate] = getTime(table);
data = table.flatten().getMatrix().getAsMat();
labels = strings(1, 9 * numPlates);
for plate = 1:numPlates
    columns = 9 * (plate - 1) + (1:9);
    data(:, columns(4:9)) = convertLengthUnitsToMeters( ...
        data(:, columns(4:9)), lengthUnits);
    labels(columns) = [ ...
        "ground_force_" + plate + "_v" + ["x" "y" "z"], ...
        "ground_force_" + plate + "_p" + ["x" "y" "z"], ...
        "ground_moment_" + plate + "_m" + ["x" "y" "z"]];
end
groundReactions.labels = labels;
groundReactions.data = data;
groundReactions.numPlates = numPlates;
end

function emg = extractEmg(table, parameters, channelNames)
names = resolveC3dLabels(getLabels(table), parameters, "ANALOG");
if isempty(channelNames)
    plateChannels = getC3dParameter(parameters, "FORCE_PLATFORM", ...
        "CHANNEL");
    indices = setdiff(1:numel(names), plateChannels(:)');
    fprintf("No <emg_channel_names> given; using the %d analog " + ...
        "channels not assigned to force plates as EMG.\n", numel(indices));
else
    [found, indices] = ismember(string(channelNames), names);
    if ~all(found)
        throw(MException("extractC3dData:missingEmgChannels", ...
            "EMG channels not found in the c3d file: %s. Available " + ...
            "analog channels: %s", strjoin(channelNames(~found), ", "), ...
            strjoin(names, ", ")))
    end
end
if isempty(indices)
    throw(MException("extractC3dData:noEmg", ...
        "The c3d file does not contain any EMG channels."))
end
[emg.time, emg.dataRate] = getTime(table);
data = table.getMatrix().getAsMat();
emg.labels = names(indices);
emg.data = data(:, indices);
end

function table = getAnalogTable(adapter, tables)
try
    table = adapter.getAnalogDataTable(tables);
catch
    throw(MException("extractC3dData:noAnalogData", ...
        "This version of OpenSim cannot read analog (EMG) data from " + ...
        "c3d files. Use OpenSim 4.5 or later, or disable EMG extraction."))
end
end

% The marker table carries the c3d POINT:UNITS, which also apply to the
% force plate points and moments
function units = getLengthUnits(markerTable, parameters)
if markerTable.hasTableMetaDataKey("Units")
    units = string(char(markerTable.getTableMetaDataAsString("Units")));
else
    units = getC3dParameter(parameters, "POINT", "UNITS");
end
if isempty(units)
    throw(MException("extractC3dData:noUnits", ...
        "The c3d file does not state its length units (POINT:UNITS)."))
end
end

function warnIfForcePlatesUncalibrated(parameters)
channels = getC3dParameter(parameters, "FORCE_PLATFORM", "CHANNEL");
units = getC3dParameter(parameters, "ANALOG", "UNITS");
if isempty(channels) || isempty(units) || size(channels, 1) < 3
    return
end
forceChannels = channels(1:3, :);
forceChannels = forceChannels(forceChannels >= 1 & ...
    forceChannels <= numel(units));
if any(upper(units(forceChannels)) == "V")
    warning("extractC3dData:uncalibratedForcePlates", ...
        "Force plate channels are in volts, so the ground reaction " + ...
        "data may not be calibrated. Calibrate the force plates in the " + ...
        "capture software before extraction.")
end
end

function labels = getLabels(table)
columnLabels = table.getColumnLabels();
labels = strings(1, double(columnLabels.size()));
for i = 1:length(labels)
    labels(i) = string(char(columnLabels.get(i - 1)));
end
end

% Rebuilds the time column from the data rate rather than reading it one
% Java call at a time, then checks it against the table's last time.
function [time, dataRate] = getTime(table)
dataRate = str2double(char(table.getTableMetaDataAsString("DataRate")));
column = table.getIndependentColumn();
numRows = double(column.size());
time = double(column.get(0)) + (0:numRows - 1)' / dataRate;
if abs(time(end) - double(column.get(numRows - 1))) > 0.5 / dataRate
    time = zeros(numRows, 1);
    for i = 1:numRows
        time(i) = double(column.get(i - 1));
    end
end
end
