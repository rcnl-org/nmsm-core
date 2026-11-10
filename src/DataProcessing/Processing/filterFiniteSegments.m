% This function is part of the NMSM Pipeline, see file for full license.
%
% Applies a zero phase-lag Butterworth filter ('low' or 'high') to each
% column. Columns with missing (NaN) samples are filtered one unbroken run
% of samples at a time, so a gap that was not filled does not spread NaN
% over the whole column. Runs too short to filter are left unfiltered with
% a warning, and missing samples stay missing.
%
% (Array of double, 2D Array of double, double, double, string)
% -> (2D Array of double)
% Filters time x columns data around missing samples

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

function data = filterFiniteSegments(time, data, order, cutoff, type)
time = time(:);
nyquist = (numel(time) - 1) / (time(end) - time(1)) / 2;
if cutoff >= nyquist
    throw(MException("filterFiniteSegments:cutoffTooHigh", ...
        "Filter cutoff %.2f Hz must be below half the sample rate " + ...
        "(%.2f Hz).", cutoff, nyquist))
end
complete = all(isfinite(data), 1);
data(:, complete) = applyFilter(time, data(:, complete), order, ...
    cutoff, type);
unfiltered = 0;
for column = find(~complete)
    finite = isfinite(data(:, column));
    edges = diff([false; finite; false]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    for run = 1:numel(starts)
        rows = starts(run):ends(run);
        if numel(rows) > 3 * order
            data(rows, column) = applyFilter(time(rows), ...
                data(rows, column), order, cutoff, type);
        else
            unfiltered = unfiltered + numel(rows);
        end
    end
end
if unfiltered > 0
    warning("filterFiniteSegments:shortSegments", ...
        "%d samples between missing data were too few to filter and " + ...
        "were left unfiltered.", unfiltered);
end
end

function data = applyFilter(time, data, order, cutoff, type)
if isempty(data)
    return
end
if type == "low"
    data = lowpassFilter(time, data, order, cutoff, false);
else
    sampleRate = (numel(time) - 1) / (time(end) - time(1));
    [b, a] = butter(order, cutoff / (sampleRate / 2), char(type));
    data = filtfilt(b, a, data);
end
end
