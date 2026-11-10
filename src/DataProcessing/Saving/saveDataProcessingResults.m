% This function is part of the NMSM Pipeline, see file for full license.
%
% Saves Data Processing results to the results directory:
%   <trial>_markers.trc, <trial>_grf.sto, <trial>_emg.sto
%       processed data in OpenSim axes (EMG normalized if requested)
%   <trial>_gait_events.sto
%       heel strikes and gait cycle time, if they were found
%   raw/<trial>_markers_raw.trc, _grf_raw.sto, _emg_raw.sto
%       data as extracted from the .c3d file, in lab axes and meters
%   intermediate/<trial>_<data>_<step>.trc/.sto
%       data after each processing step, in lab axes, if
%       <save_intermediate_files> is true
%
% (struct, struct, struct, string) -> (None)
% Writes Data Processing results to files

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

function saveDataProcessingResults(results, inputs, params, ...
    resultsDirectory)
trialPrefix = fullfile(resultsDirectory, inputs.trialName);
rawPrefix = fullfile(makeDirectory(resultsDirectory, "raw"), ...
    inputs.trialName);
dataTypes = ["markers", "groundReactions", "emg"];
fileNames = ["markers", "grf", "emg"];
for i = 1:numel(dataTypes)
    isMarkers = dataTypes(i) == "markers";
    if isfield(results.raw, dataTypes(i))
        writeData(results.raw.(dataTypes(i)), ...
            rawPrefix + "_" + fileNames(i) + "_raw", isMarkers);
    end
    if ~isfield(results.processed, dataTypes(i))
        continue
    end
    writeData(results.processed.(dataTypes(i)), ...
        trialPrefix + "_" + fileNames(i), isMarkers);
    if params.saveIntermediateFiles
        intermediatePrefix = fullfile(makeDirectory(resultsDirectory, ...
            "intermediate"), inputs.trialName + "_" + fileNames(i));
        steps = results.steps.(dataTypes(i));
        stepNames = string(fieldnames(steps))';
        for step = stepNames
            data = results.raw.(dataTypes(i));
            data.data = steps.(step);
            writeData(data, intermediatePrefix + "_" + step, isMarkers);
        end
    end
end
if ~isempty(results.gaitEvents)
    writeGaitEvents(results.gaitEvents, trialPrefix + "_gait_events.sto");
end
end

function directory = makeDirectory(resultsDirectory, name)
directory = fullfile(resultsDirectory, name);
if ~exist(directory, "dir")
    mkdir(directory);
end
end

% Markers are written as .trc, everything else as .sto
function writeData(data, filePrefix, isMarkers)
import org.opensim.modeling.STOFileAdapter
if isMarkers
    writeToTrc(data.labels, data.time, data.data, data.dataRate, "m", ...
        filePrefix + ".trc");
else
    STOFileAdapter.write(makeTimeSeriesTable(data.labels, data.time, ...
        data.data), filePrefix + ".sto");
end
end

% One row per heel strike, sorted by time, with the force plate it was on.
% The gait cycle time is stored in the file header.
function writeGaitEvents(gaitEvents, fileName)
import org.opensim.modeling.STOFileAdapter
times = [];
plates = [];
for plate = 1:numel(gaitEvents.heelStrikeTimes)
    times = [times; gaitEvents.heelStrikeTimes{plate}(:)]; %#ok<AGROW>
    plates = [plates; plate * ones(numel( ...
        gaitEvents.heelStrikeTimes{plate}), 1)]; %#ok<AGROW>
end
[times, order] = sort(times);
table = makeTimeSeriesTable("force_plate", times, plates(order));
table.addTableMetaDataString("gait_cycle_time", ...
    sprintf("%.6f", gaitEvents.gaitCycleTime));
STOFileAdapter.write(table, fileName);
end
