% This function is part of the NMSM Pipeline, see file for full license.
%
% Fills gaps of missing (NaN) samples in each column by interpolation.
% Gaps longer than maxGapFrames, missing samples at the start or end of a
% column, and columns with fewer than two samples are left as NaN.
%
% (2D Array of double, string, double) -> (2D Array of double)
% Fills short gaps in time x columns data

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

function data = fillDataGaps(data, interpolationMethod, maxGapFrames)
missing = isnan(data);
columns = any(missing, 1) & sum(~missing, 1) >= 2;
if maxGapFrames == 0 || ~any(columns)
    return
end
% MaxGap is the distance between the samples on either side of a gap, so
% a gap of n missing frames has size n + 1
data(:, columns) = fillmissing(data(:, columns), interpolationMethod, ...
    "MaxGap", maxGapFrames + 1, "EndValues", "none");
end
