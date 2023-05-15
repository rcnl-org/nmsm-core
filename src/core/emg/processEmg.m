% This function is part of the NMSM Pipeline, see file for full license.
%
% RCNL's protocol for turning a matrix of double of EMG data into processed
% EMG data that is filtered, demeaned, and rectified as necessary. Default
% values are used if missing from params struct.
%
% Parameters:
%    filterOrder: Order of the Butterworth filter to use
%    highPassCutoff: Cutoff frequency for the high pass filter
%    lowPassCutoff: Cutoff frequency for the low pass filter
%
% (2D Array of double, 1D Array of double, struct) -> (2D Array of double)
% Processes the input EMG data by RCNL's protocol

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function processedEmgData = processEmg(emgData, emgTime, params)

sampleRate = length(emgTime) / (emgTime(end) - emgTime(1));

% High pass filter the data
order = valueOrAlternate(params, "filterOrder", 4);
highPassCutoff = valueOrAlternate(params, "highPassCutoff", 10);
[b,a] = butter(order, 2 * highPassCutoff/sampleRate, 'high');
emgData = filtfilt(b, a, emgData);

% Demean
emgData = emgData-ones(size(emgData, 1), 1) * mean(emgData);

% Rectify
emgData = abs(emgData);

% Low pass filter
lowPassCutoff = valueOrAlternate(params, "lowPassCutoff", 40);
[b,a] = butter(order, 2 * lowPassCutoff / sampleRate);
emgData = filtfilt(b, a, emgData);

% Remove any negative EMG values that may still exist
emgData(emgData < 0) = 0;

processedEmgData = emgData';

end

