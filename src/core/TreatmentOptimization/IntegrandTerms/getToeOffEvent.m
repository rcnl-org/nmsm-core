% This function is part of the NMSM Pipeline, see file for full license.
%
% This function identifies the toe off event by detecting changes in
% slope of the normal force. To avoid erroneous detection of a toe off
% event, the slope of the normal force must be negative for at least 10% of
% the time. Detects only one toe off event (use for only one gait cycle). 
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

function toeOffEvent = getToeOffEvent(slope)

timePadding = round(length(slope) * 0.10) + 1;
toeOffEvent = [];
for i = 1 + timePadding : length(slope)
    if slope(i) == 0 && all(slope(i - timePadding : i - 1) < 0)
        toeOffEvent = i;
    end
end
end