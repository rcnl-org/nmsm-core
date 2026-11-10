% This function is part of the NMSM Pipeline, see file for full license.
%
% Finds heel strikes on each force plate from its vertical force. A heel
% strike is a sample where the vertical force rises above forceThreshold,
% the force was below the threshold 1/15 s earlier, and the force is above
% twice the threshold 1/75 s later. Checking before and after the crossing
% rejects noise spikes and brief touches.
%
% (Array of double, 2D Array of double, double) -> (Cell array)
% Returns heel strike times (column) for each force plate

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

function heelStrikeTimes = detectHeelStrikes(time, verticalForces, ...
    forceThreshold)
time = time(:);
sampleRate = (numel(time) - 1) / (time(end) - time(1));
framesBack = round(sampleRate / 15);
framesForward = max(round(sampleRate / 75), 1);
numFrames = numel(time);
heelStrikeTimes = cell(1, size(verticalForces, 2));
for plate = 1:size(verticalForces, 2)
    force = verticalForces(:, plate);
    frames = find(force(1:end - 1) < forceThreshold & ...
        force(2:end) >= forceThreshold) + 1;
    past = frames - framesBack;
    future = frames + framesForward;
    valid = past >= 1 & future <= numFrames;
    frames = frames(valid);
    keep = force(past(valid)) < forceThreshold & ...
        force(future(valid)) > 2 * forceThreshold;
    heelStrikeTimes{plate} = time(frames(keep));
end
end
