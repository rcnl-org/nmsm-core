% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, 2D matrix, Array of number, Array of string) -> (Array of number)
%
% Applies a time range to a cost or constraint term.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [termValues, term] = applyTermTimeRanges(termValues, term, time)
if isfield(term, "time_ranges")
    if ~isnumeric(term.time_ranges)
        term.time_ranges = str2double(split(term.time_ranges));
        assert(mod(length(term.time_ranges), 2) == 0, ...
            "Term time_ranges must contain an even number of values.");
        assert(all(sign(diff(term.time_ranges)) == 1), "Term " + ...
            "time_ranges values must be strictly increasing.");
        assert(term.time_ranges(end) <= 1, "Term time_ranges uses " + ...
            "time normalized from 0 to 1 and should not have values " + ...
            "greater than 1.");
    end
    assert(length(term.time_ranges) > 1, ...
        "Term time_ranges must contain an even number of values.");
    time = time / time(end);
    excludedIndices = true(size(time));
    for i = 1 : length(term.time_ranges) / 2
        excludedIndices(time >= term.time_ranges(2 * i - 1) & ...
            time <= term.time_ranges(2 * i)) = false;
    end
    termValues(excludedIndices) = 0;
end
end
