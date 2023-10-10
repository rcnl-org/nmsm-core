% This function is part of the NMSM Pipeline, see file for full license.
%
% This function identifies the heel strike event by detecting changes in
% slope of the normal force. To avoid erroneous detection of a heel strike
% event, the slope of the normal force must be positive for at least 10% of
% the time. Detects only one heel strike (use for only one gait cycle). 
%
% (Array of number) -> (Number)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function heelStrikeEvent = getHeelStrikeEvent(slope)

timePadding = round(length(slope) * 0.10);
heelStrikeEvent = [];
for i = 2 : length(slope) - timePadding
    if slope(i - 1) == 0 && all(slope(i : i + timePadding) > 0)
        heelStrikeEvent = i;
    end
end
end