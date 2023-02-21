function nNodes = calcNumBsplNodesFromCutoffFreq(time, data, params)

close all

% Define non-adjusted parameters
allowError = 1; % in percent - 10% used in Schleicher and Biloti (2008)
fourierDegree = 1; % add a linear polynomial to the Fourier fitting process
    % to create a periodic function artificially
nNodes = 10; % starting guess - should work well for >= one movement cycle

% Reshape time series data
time = time'; 
curves = data';

% Extract relevant parameters
fCutoff = params.fCutoff;
splineDegree = params.splineDegree;
plotFlag = params.plotFlag;

% fprintf('The specified cutoff frequency is %d Hz\n', fCutoff);

% Calculate sampling frequency from time vector containing
% truncated time values
% Estimating the sampling frequency with a larger number of frames
% minimizes the risk of calculating the true sampling frequency incorrectly 
nFrames = length(time);

if nFrames > 100
    fSample = round(1/(time(11,1)-time(1,1)))*10;
else
    fSample = round(10/(time(101,1)-time(1,1)))*10;
end

% Recalculate time vector based on correct sampling frequency to
% correct truncation errors in time vector
dt = 1/fSample;
time = linspace(0,(nFrames-1)*dt,nFrames)';

% Cycle through all curves to find the number of B-spline nodes
% that reproduces all Fourier coefficients to within 10% error
nCurves = size(curves,2);
curvesSpl = zeros(nFrames,nCurves);
maxErrors = zeros(1,nCurves);
maxError = 100;

% fprintf('Optimal number of B-spline nodes being found for %d curves\n',...
%     nCurves);

while maxError > allowError
    
    % Increment number of nodes
    nNodes = nNodes+1;
    
    % Define Fourier fitting parameters
    fFund = 1/time(end,1); % define fundamental frequency based on final
        % time
    nHarmonics = round(fCutoff/fFund); % find closest number of harmonics
        % for selected cutoff frequency
            
    % Cycle through curves and calculate percent errors
    for i = 1:nCurves
        
        % Extract current curve
        curve = curves(:,i);
        
        % Fit current curve using Fourier series + a linear term
        coefsOrig = polyFourierCoefs(time,curve,fFund,fourierDegree,...
            nHarmonics);

        % Fit the original function with a B-spline
        [curveSpl,~,~] = BsplineFit(time,curve,splineDegree,nNodes);

        % Fourier-fit the B-spline fit to calculate the Fourier
        % coefficients for comparison
        coefsSpl = polyFourierCoefs(time,curveSpl,fFund,fourierDegree,...
            nHarmonics);

        % Calculate percent error in each Fourier coefficient relative to
        % the largest absolute coefficient value
        % Also make the maximum value non-zero in case a flat curve = 0 is
        % being fitted
        % Omit checking the first two coefficients since they define
        % the linear term
        coefsMax = max(max(abs(coefsOrig(3:end,1))),1e-8);
        percentErrors = abs((coefsSpl(3:end,1)-coefsOrig(3:end,1))/...
            coefsMax)*100;
        
        % Calculate maximum error in all Fourier coefficients for current
        % curve
        maxErrors(1,i) = max(percentErrors);
        
        % Store B-spline fitted curve
        curvesSpl(:,i) = curveSpl;

    end
    
    % Calculate maximum error across all fitted curves
    maxError = max(maxErrors);
    
%     fprintf('maxError = %3.2f for %d nodes\n', maxError, nNodes);
    
end

% fprintf('The optimal number of B-spline nodes is %d\n', nNodes);

% Generate comparison plots if desired
if plotFlag
    
    for i = 1:nCurves
        
        % Extract current curve
        curve = curves(:,i);
        
        % Fourier fit original curve with linear term added
        coefsOrig = polyFourierCoefs(time,curve,fFund,fourierDegree,...
            nHarmonics);
        curveFou = polyFourierCurves(coefsOrig,fFund,time,fourierDegree,0);
        
        % Lowpass filter original curve using a 4th order zero phase lag
        % Butterworth filter
        order = 4;
        curveFlt = lowpassFilter(time,curve,order,fCutoff,0);
        
        % B-spline fit original curve
        [curveSpl,~,~] = BsplineFit(time,curve,splineDegree,nNodes);
        
        % Plot original, Fourier+linear, B-spline, and filtered curves
        plot(time,curve,'k-','LineWidth',2)
        title(sprintf('Curve %d', i))
        xlabel('time')
        ylabel('quantity')
        hold on
        plot(time,curveFou,'r-','LineWidth',2)
        plot(time,curveFlt,'g-','LineWidth',2)
        plot(time,curveSpl,'b-','LineWidth',2)
        legend('Original','Fourier','Filter','Bspline')
        pause
        
        close all
        
    end
    
end

end
    
    
