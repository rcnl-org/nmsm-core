% This function is part of the NMSM Pipeline, see file for full license.
%
% Saves the data extracted from the .c3d file to <results>/raw:
% <trial>_markers_raw.trc (m), <trial>_grf_raw.sto (N, m, N*m), and
% <trial>_emg_raw.sto (V). Only the data types that were extracted are
% written. Heel strikes found from the ground reactions are written to
% <results>/<trial>_gait_events.sto.
%
% (struct, struct, string) -> (None)
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

function saveDataProcessingResults(results, inputs, resultsDirectory)
rawDirectory = fullfile(resultsDirectory, "raw");
if ~exist(rawDirectory, "dir")
    mkdir(rawDirectory);
end
raw = results.raw;
if isfield(raw, "markers")
    writeToTrc(raw.markers.labels, raw.markers.time, raw.markers.data, ...
        raw.markers.dataRate, "m", fullfile(rawDirectory, ...
        inputs.trialName + "_markers_raw.trc"));
end
if isfield(raw, "groundReactions")
    writeDataToSto(raw.groundReactions, fullfile(rawDirectory, ...
        inputs.trialName + "_grf_raw.sto"));
end
if isfield(raw, "emg")
    writeDataToSto(raw.emg, fullfile(rawDirectory, ...
        inputs.trialName + "_emg_raw.sto"));
end
if ~isempty(results.gaitEvents)
    writeGaitEvents(results.gaitEvents, fullfile(resultsDirectory, ...
        inputs.trialName + "_gait_events.sto"));
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

function writeDataToSto(data, fileName)
import org.opensim.modeling.STOFileAdapter
STOFileAdapter.write(makeTimeSeriesTable(data.labels, data.time, ...
    data.data), fileName);
end
