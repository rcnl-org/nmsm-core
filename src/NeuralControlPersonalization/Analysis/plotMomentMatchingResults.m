function plotMomentMatchingResults(idStoFile,ncpStoFile)

% Read in ID and NCP joint moments
idData = importdata(idStoFile);
ncpData = importdata(ncpStoFile);

idMoments = idData.data(:,[8 11 13]);
ncpMoments = ncpData.data(:,2:4);

time = idData.data(:,1);

% Plot ID and NCP moments
subplot(1,3,1), plot(time,idMoments(:,1),'k-',time,ncpMoments(:,1),'r-')
title('Hip Moment Comparison')
subplot(1,3,2), plot(time,idMoments(:,2),'k-',time,ncpMoments(:,2),'r-')
title('Knee Moment Comparison')
subplot(1,3,3), plot(time,idMoments(:,3),'k-',time,ncpMoments(:,3),'r-')
title('Ankle Moment Comparison')

% Calculate RMS errors between ID and NCP moments
rmsErrors = zeros(1,3);

for i = 1:3
    rmsErrors(1,i) = calcRMSError(idMoments(:,i),ncpMoments(:,i));
end

rmsErrors

end

%--------------------------------------------------------------------------
function rmsError = calcRMSError(reference,predicted)

errors = predicted-reference;
sumErrorsSquared = errors'*errors;
nPts = size(reference,1);
rmsError = sqrt(sumErrorsSquared/nPts);

end