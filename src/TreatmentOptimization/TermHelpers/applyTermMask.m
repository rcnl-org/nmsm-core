% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, 2D matrix, Array of number, Array of string) -> (Array of number)
%
% Applies a mask to a cost or constraint term.

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

function [termValues, term] = applyTermMask(termValues, term, time)
if isfield(term, "mask")
    if ~isnumeric(term.mask)
        term.mask = str2double(split(term.mask));
        assert(mod(length(term.mask), 2) == 0, ...
            "Term masks must contain an even number of values.");
        assert(all(sign(diff(term.mask)) == 1), "Term mask values " + ...
            "must be strictly increasing.");
        assert(term.mask(end) <= 1, "Term masks use time normalized " + ...
            "from 0 to 1 and should not have values greater than 1.");
    end
    time = time / time(end);
    excludedIndices = true(size(time));
    for i = 1 : length(term.mask) / 2
        excludedIndices(time >= term.mask(2 * i - 1) & ...
            time <= term.mask(2 * i)) = false;
    end
    termValues(excludedIndices) = 0;
end
end
