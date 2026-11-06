% This function is part of the NMSM Pipeline, see file for full license.
%
% Warns about missing (NaN) samples in extracted data. Columns are grouped
% by name (three per marker, one per channel). A group that is entirely
% NaN is reported and left as is. Groups with gaps longer than
% maxGapFrames are reported because they will not be filled by
% interpolation. Groups with only short gaps are listed for information.
%
% (string, Array of string, 2D Array of double, double) -> (struct)
% Reports missing data and returns which groups are affected

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

function report = reportMissingData(dataName, names, data, maxGapFrames)
groupSize = size(data, 2) / numel(names);
report.allMissing = string([]);
report.longGaps = string([]);
report.shortGaps = string([]);
for i = 1:numel(names)
    missing = any(isnan(data(:, (i - 1) * groupSize + (1:groupSize))), 2);
    if ~any(missing)
        continue
    end
    if all(missing)
        report.allMissing(end + 1) = names(i);
    elseif longestRun(missing) > maxGapFrames
        report.longGaps(end + 1) = names(i);
    else
        report.shortGaps(end + 1) = names(i);
    end
end
if ~isempty(report.allMissing)
    warning("reportMissingData:allMissing", ...
        "%s with no data (left as NaN): %s", dataName, ...
        strjoin(report.allMissing, ", "));
end
if ~isempty(report.longGaps)
    warning("reportMissingData:longGaps", ...
        "%s with gaps longer than %d frames (not interpolated): %s", ...
        dataName, maxGapFrames, strjoin(report.longGaps, ", "));
end
if ~isempty(report.shortGaps)
    fprintf("%s with gaps of %d frames or fewer (will be " + ...
        "interpolated): %s\n", dataName, maxGapFrames, ...
        strjoin(report.shortGaps, ", "));
end
end

function runLength = longestRun(isMissing)
edges = diff([0; isMissing(:); 0]);
runLength = max(find(edges == -1) - find(edges == 1));
end
