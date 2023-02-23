%--------------------------------------------------------------------------
function dataOut = lowpassFilter(timeIn,dataIn,order,fCutoff,plotFlag)
% Perform zero phase-lag lowpass butterworth filter on input data

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