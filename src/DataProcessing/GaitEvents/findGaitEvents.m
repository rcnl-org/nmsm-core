% This function is part of the NMSM Pipeline, see file for full license.
%
% Finds heel strikes and the average gait cycle time from ground reaction
% data in lab axes. The vertical force is low pass filtered before heel
% strikes are found. The filter cutoff starts at 6 Hz and is reset to 14
% divided by the gait cycle time until it changes by less than 1%, so the
% filtering suits the subject's walking speed.
%
% (struct, Array of double, struct) -> (struct)
% Returns heel strike times per plate and the gait cycle time

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

function gaitEvents = findGaitEvents(groundReactions, labToOpenSimAxes, ...
    gaitCycleParams)
time = groundReactions.time;
verticalForces = fillmissing(getVerticalForces(groundReactions, ...
    labToOpenSimAxes), "linear", "EndValues", "nearest");
verticalForces(isnan(verticalForces)) = 0;
nyquist = groundReactions.dataRate / 2;
cutoff = 6;
for iteration = 1:20
    filtered = lowpassFilter(time, verticalForces, 2, cutoff, false);
    heelStrikeTimes = detectHeelStrikes(time, filtered, ...
        gaitCycleParams.heelStrikeForceThreshold);
    gaitCycleTime = calcGaitCycleTime(heelStrikeTimes, ...
        gaitCycleParams.forcePlateLayout);
    newCutoff = min(14 / gaitCycleTime, 0.9 * nyquist);
    converged = abs(newCutoff - cutoff) / cutoff < 0.01;
    cutoff = newCutoff;
    if converged
        break
    end
end
gaitEvents.heelStrikeTimes = heelStrikeTimes;
gaitEvents.gaitCycleTime = gaitCycleTime;
gaitEvents.filterCutoff = cutoff;
fprintf("Found %s heel strikes on force plates 1-%d; average gait " + ...
    "cycle time %.3f s.\n", strjoin(string(cellfun(@numel, ...
    heelStrikeTimes)), "/"), numel(heelStrikeTimes), gaitCycleTime);
end
