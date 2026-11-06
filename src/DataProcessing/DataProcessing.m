% This function is part of the NMSM Pipeline, see file for full license.
%
% Runs Data Processing: extracts marker, ground reaction, and EMG data from
% a .c3d file, converts lengths to meters, and reports missing data.
%
% (struct, struct, App) -> (struct)
% Extracts and checks data from a .c3d file

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

function results = DataProcessing(inputs, params, app)
if nargin < 3
    app = [];
end
updateRunStageGui(app, 'ExtractingDataLabel', 'on');
results.raw = extractC3dData(inputs.c3dFile, inputs.extract);
if isfield(results.raw, "markers")
    results.missingData.markers = reportMissingData("Markers", ...
        results.raw.markers.labels, results.raw.markers.data, ...
        params.markers.gapFill.maxGapFrames);
end
if isfield(results.raw, "groundReactions")
    results.missingData.groundReactions = reportMissingData( ...
        "Ground reaction columns", results.raw.groundReactions.labels, ...
        results.raw.groundReactions.data, ...
        params.groundReactions.gapFill.maxGapFrames);
end
if isfield(results.raw, "emg")
    results.missingData.emg = reportMissingData("EMG channels", ...
        results.raw.emg.labels, results.raw.emg.data, 0);
end
updateRunStageGui(app, 'ExtractingDataLabel', 'off');
end
