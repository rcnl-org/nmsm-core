% This function is part of the NMSM Pipeline, see file for full license.
%
% Processes extracted marker data: fills short gaps by interpolation, low
% pass filters, and reorients the data into OpenSim axes. Returns the
% processed markers and the data after each step for intermediate files.
%
% (struct, struct, double, Array of double) -> (struct, struct)
% Returns processed markers and the result of each processing step

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

function [markers, steps] = processMarkerData(markers, params, ...
    gaitCycleTime, labToOpenSimAxes)
markers.data = fillDataGaps(markers.data, ...
    params.gapFill.interpolationMethod, params.gapFill.maxGapFrames);
steps.gapfilled = markers.data;
cutoff = resolveCutoffFrequency(params.lowPassFilter, gaitCycleTime, ...
    "Marker low pass filter");
markers.data = filterFiniteSegments(markers.time, markers.data, ...
    params.lowPassFilter.order, cutoff, "low");
steps.filtered = markers.data;
markers.data = reorientLabData(markers.data, labToOpenSimAxes);
end
