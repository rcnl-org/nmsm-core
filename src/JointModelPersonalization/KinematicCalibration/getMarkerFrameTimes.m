% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns the times of the marker frames between the start
% and finish times. The times are read from the marker table, so no frame
% is skipped by rounding error. Each end of the range includes a frame
% within half a frame of it, so the range does not need to be typed to
% the exact precision of the marker file.
%
% (MarkersReference, number, number) -> (Array of number)
% Returns the marker frame times in the given time range

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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

function frameTimes = getMarkerFrameTimes(markersReference, startTime, ...
    finishTime)
tableTimes = markersReference.getMarkerTable().getIndependentColumn();
times = zeros(1, tableTimes.size());
for i = 1:numel(times)
    times(i) = tableTimes.get(i - 1);
end
if nargin < 2
    startTime = times(1);
end
if nargin < 3
    finishTime = times(end);
end
halfFrame = 0.5 / markersReference.getSamplingFrequency();
frameTimes = times(times >= startTime - halfFrame & ...
    times <= finishTime + halfFrame);
assert(~isempty(frameTimes), sprintf("No marker frames are in the " + ...
    "time range %g to %g s.", startTime, finishTime))
end
