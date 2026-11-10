% This function is part of the NMSM Pipeline, see file for full license.
%
% Calculates the average gait cycle time from heel strike times on each
% force plate.
%
% treadmill: each foot stays on its own plate, so every interval between
% consecutive heel strikes on one plate is a gait cycle.
% overground: each foot is on at most one plate at a time and feet
% alternate, so with all heel strikes sorted by time, a heel strike and the
% second one after it are made by the same foot one gait cycle apart.
%
% Intervals outside half to one and a half times the median interval (e.g.
% from a missed heel strike) are left out of the average with a warning.
%
% (Cell array, string) -> (double, Array of double)
% Returns the average gait cycle time and the intervals it was found from

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

function [gaitCycleTime, intervals] = calcGaitCycleTime( ...
    heelStrikeTimes, forcePlateLayout)
switch forcePlateLayout
    case "treadmill"
        intervals = cell2mat(cellfun(@(times) diff(times(:)), ...
            heelStrikeTimes(:), "UniformOutput", false));
    case "overground"
        intervals = overgroundIntervals(heelStrikeTimes);
end
if isempty(intervals)
    throw(MException("calcGaitCycleTime:tooFewHeelStrikes", ...
        "Found %d heel strike(s), which is not enough to calculate " + ...
        "the gait cycle time for a %s layout. Check " + ...
        "<force_plate_layout> and <heel_strike_force_threshold>, or " + ...
        "give <gait_cycle_time>.", numel(cell2mat(heelStrikeTimes(:))), ...
        forcePlateLayout))
end
typical = median(intervals);
outliers = intervals < 0.5 * typical | intervals > 1.5 * typical;
if any(outliers)
    warning("calcGaitCycleTime:outlierIntervals", ...
        "Left %d of %d gait cycle intervals out of the average " + ...
        "because they are far from the median (%.3f s): %s s", ...
        sum(outliers), numel(intervals), typical, ...
        strjoin(compose("%.3f", intervals(outliers)), ", "));
end
gaitCycleTime = mean(intervals(~outliers));
end

function intervals = overgroundIntervals(heelStrikeTimes)
times = [];
plates = [];
for plate = 1:numel(heelStrikeTimes)
    times = [times; heelStrikeTimes{plate}(:)]; %#ok<AGROW>
    plates = [plates; plate * ones(numel(heelStrikeTimes{plate}), 1)]; %#ok<AGROW>
end
[times, order] = sort(times);
plates = plates(order);
if any(diff(plates) == 0)
    warning("calcGaitCycleTime:repeatedPlate", ...
        "Consecutive heel strikes were found on the same force plate, " + ...
        "so a foot may have landed on a plate twice or both feet " + ...
        "touched one plate. The overground gait cycle time assumes " + ...
        "feet alternate between plates.");
end
intervals = times(3:end) - times(1:end - 2);
end
