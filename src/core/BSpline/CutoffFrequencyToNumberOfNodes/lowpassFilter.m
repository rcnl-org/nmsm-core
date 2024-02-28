% This function is part of the NMSM Pipeline, see file for full license.
%
% Lowpass filters data at a given cutoff frequency, with optional plotting.
% Uses zero phase-lag butterworth filtering. 
% 
% (Array of double, Array of double, double, double, logical) 
% -> (Array of double)
% Lowpass filters input data. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Benjamin J. Fregly                                           %
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

function yFilt = lowpassFilter(t,y,order,fCutoff,plotFlag)
% Perform zero phase-lag lowpass Butterworth filter on input data

% Set up filter inputs
dt = t(2)-t(1);
fSample = 1/dt; % Sampling frequency in Hz
normCutoff = fCutoff/(fSample/2);

% Create butterworth filter
[b,a] = butter(order,normCutoff);

% Demean input data to minimize edge effects
yMean = mean(y);
yDemeaned = y-yMean;

% Use filtfilt to perform zero phase-lag filtering on demeaned data
yFiltDemeaned = filtfilt(b,a,yDemeaned);

% Add mean value back into filtered data
yFilt = yFiltDemeaned+yMean;

% Plot original and filtered data if desired
if plotFlag
    plot(t,y,'k-')
    hold on
    plot(t,yFilt,'b-')
    xlabel('time')
    ylabel('data')
    pause
    close all
end

end