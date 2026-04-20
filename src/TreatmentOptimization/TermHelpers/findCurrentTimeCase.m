% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of double, struct) -> (double)
%
% Compares current and expected time ranges for fetching precomputed data.

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

function timeCase = findCurrentTimeCase(time, inputs)
try
    timeCase = inputs.timeCase;
catch
    if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
            max(abs(time ./ time(end) - inputs.collocationTimeOriginal ./ ...
            inputs.collocationTimeOriginal(end))) < 1e-6
        timeCase = 1;
    elseif all(size(time) == size(inputs.collocationTimeOriginalWithEnd)) &&...
            max(abs(time ./ time(end) - ...
            inputs.collocationTimeOriginalWithEnd ./ ...
            inputs.collocationTimeOriginalWithEnd(end))) < 1e-6
        timeCase = 2;
    elseif size(time) == [2, 1]
        timeCase = 3;
    else
        timeCase = 4;
    end
end
end
