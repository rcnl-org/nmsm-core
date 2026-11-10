% This function is part of the NMSM Pipeline, see file for full license.
%
% Returns a filter's cutoff frequency in Hz: <cutoff_frequency> if it was
% given, otherwise <cutoff_gait_cycle_multiple> divided by the gait cycle
% time.
%
% (struct, double, string) -> (double)
% Returns the cutoff frequency of a parsed filter block

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

function cutoff = resolveCutoffFrequency(filter, gaitCycleTime, filterName)
if ~isempty(filter.cutoffFrequency)
    cutoff = filter.cutoffFrequency;
elseif isempty(gaitCycleTime)
    throw(MException("resolveCutoffFrequency:noGaitCycleTime", ...
        "The %s cutoff is a multiple of the gait cycle frequency, but " + ...
        "no gait cycle time is available. Give <gait_cycle_time> or " + ...
        "<cutoff_frequency>.", filterName))
else
    cutoff = filter.cutoffGaitCycleMultiple / gaitCycleTime;
end
fprintf("%s: order %d, cutoff %.2f Hz\n", filterName, filter.order, cutoff);
end
