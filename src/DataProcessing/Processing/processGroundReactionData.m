% This function is part of the NMSM Pipeline, see file for full license.
%
% Processes extracted ground reaction data, nine columns per force plate
% (force, electrical center, moment), in this order:
%   1. Fill short gaps by interpolation.
%   2. Optionally remove a DC offset from each force and moment column:
%      its mean over the samples where the plate is unloaded. A plate is
%      unloaded when its vertical force is below <force_threshold>, or
%      below <heel_strike_force_threshold> if no force threshold is given.
%   3. Optionally set forces and moments to zero where the vertical force
%      is below <force_threshold>.
%   4. Low pass filter the forces and moments. The electrical center is
%      fixed, so it is not filtered.
%   5. Reorient the data into OpenSim axes.
% Returns the processed data and the data after each step for
% intermediate files.
%
% (struct, struct, double, double, Array of double) -> (struct, struct)
% Returns processed ground reactions and the result of each step

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

function [groundReactions, steps] = processGroundReactionData( ...
    groundReactions, params, heelStrikeForceThreshold, gaitCycleTime, ...
    labToOpenSimAxes)
groundReactions.data = fillDataGaps(groundReactions.data, ...
    params.gapFill.interpolationMethod, params.gapFill.maxGapFrames);
steps.gapfilled = groundReactions.data;
plateColumns = 9 * (0:groundReactions.numPlates - 1)' + [1:3 7:9];

if params.removeOffset
    loadThreshold = heelStrikeForceThreshold;
    if ~isempty(params.forceThreshold)
        loadThreshold = params.forceThreshold;
    end
    groundReactions = removeOffsets(groundReactions, plateColumns, ...
        loadThreshold, labToOpenSimAxes);
    steps.offset_removed = groundReactions.data;
end

if ~isempty(params.forceThreshold)
    vertical = getVerticalForces(groundReactions, labToOpenSimAxes);
    for plate = 1:groundReactions.numPlates
        groundReactions.data(vertical(:, plate) < ...
            params.forceThreshold, plateColumns(plate, :)) = 0;
    end
    steps.thresholded = groundReactions.data;
end

cutoff = resolveCutoffFrequency(params.lowPassFilter, gaitCycleTime, ...
    "Ground reaction low pass filter");
columns = reshape(plateColumns', 1, []);
groundReactions.data(:, columns) = filterFiniteSegments( ...
    groundReactions.time, groundReactions.data(:, columns), ...
    params.lowPassFilter.order, cutoff, "low");
steps.filtered = groundReactions.data;
groundReactions.data = reorientLabData(groundReactions.data, ...
    labToOpenSimAxes);
end

function groundReactions = removeOffsets(groundReactions, plateColumns, ...
    loadThreshold, labToOpenSimAxes)
vertical = getVerticalForces(groundReactions, labToOpenSimAxes);
for plate = 1:groundReactions.numPlates
    unloaded = vertical(:, plate) < loadThreshold;
    if ~any(unloaded)
        warning("processGroundReactionData:alwaysLoaded", ...
            "Force plate %d is never unloaded, so its offset was not " + ...
            "removed.", plate);
        continue
    end
    columns = plateColumns(plate, :);
    groundReactions.data(:, columns) = groundReactions.data(:, columns) ...
        - mean(groundReactions.data(unloaded, columns), 1, "omitnan");
end
end
