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

function dataOut = lowpassFilter(timeIn,dataIn,order,fCutoff,plotFlag)

% Pad front and back of data with complete data set to eliminate
% filter transients at the start and end
% This step assumes the data are periodic
npts = length(dataIn);
dt = timeIn(2,1)-timeIn(1,1);
dataInLong = [dataIn(1:npts-1,1); dataIn; dataIn(2:npts,1)];

% dataMirrored = zeros(npts-1,1);
% for i = 1:npts-1
%     dataMirrored(i,1) = dataIn(npts-i,1);
% end
% dataInLong = [dataMirrored; dataIn; dataMirrored];
% dataInLong = [dataIn(1,1)*ones(npts-1,1); dataIn; dataIn(npts,1)*ones(npts-1,1)]; % Old choice
% dataInLong = [dataIn(npts,1)*ones(npts-1,1); dataIn; dataIn(1,1)*ones(npts-1,1)];

% Set up filter inputs
fSample = 1/dt; % Sampling frequency in Hz
normCutoff = fCutoff/(fSample/2);

% Create butterworth filer
[b,a] = butter(order,normCutoff);

% Use filtfilt to perform zero phase-lag filtering
dataOutLong = filtfilt(b,a,dataInLong);
dataOut = dataOutLong(npts:2*npts-1);

% Plot original and filtered data if desired
if plotFlag
    plot(timeIn,dataIn,'k-')
    hold on
    plot(timeIn,dataOut,'b-')
    xlabel('time')
    ylabel('data')
    pause
    close all
end