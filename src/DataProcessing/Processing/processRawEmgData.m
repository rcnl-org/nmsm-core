% This function is part of the NMSM Pipeline, see file for full license.
%
% Processes raw EMG into envelopes, one channel at a time:
%   1. High pass filter to remove movement artifact.
%   2. Subtract each channel's mean over time and rectify.
%   3. Low pass filter to form the envelope, clipping any negative values
%      left by the filter to zero.
%   4. Optionally divide each channel by its maximum so it ranges from 0
%      to 1.
% Returns the processed EMG and the data after each step for intermediate
% files.
%
% (struct, struct, double) -> (struct, struct)
% Returns processed EMG and the result of each processing step

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

function [emg, steps] = processRawEmgData(emg, params, gaitCycleTime)
cutoff = resolveCutoffFrequency(params.highPassFilter, gaitCycleTime, ...
    "EMG high pass filter");
emg.data = filterFiniteSegments(emg.time, emg.data, ...
    params.highPassFilter.order, cutoff, "high");
steps.highpass = emg.data;
emg.data = abs(emg.data - mean(emg.data, 1, "omitnan"));
steps.rectified = emg.data;
cutoff = resolveCutoffFrequency(params.lowPassFilter, gaitCycleTime, ...
    "EMG low pass filter");
emg.data = filterFiniteSegments(emg.time, emg.data, ...
    params.lowPassFilter.order, cutoff, "low");
emg.data(emg.data < 0) = 0;
steps.lowpass = emg.data;
if params.normalize
    maximums = max(emg.data, [], 1, "omitnan");
    maximums(~(maximums > 0)) = 1;
    emg.data = emg.data ./ maximums;
end
end
