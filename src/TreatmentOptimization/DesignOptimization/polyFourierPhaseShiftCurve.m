function y = polyFourierPhaseShiftCurve(t,coefs,phi)

% Function to compute up to 7th degree polynomial plus Fourier
% fitted values given the pre-computed polynomial and Fourier
% coefficients saved in a column vector.
% This version assumes:
% 1) the input time vector is normalized to a final time = 1,
% 2) the input time vector can have non-equally spaced points,
% 3) the polynomial is linear with the coefficient of the linear term set
%    equal to zero, and
% 4) a phase shift phi (in radians) is added to the reconstructed curve,
%    where the phase shift is positive for a backward shift in time.
%
% Author: B.J. Fregly
%         January 22, 2025

% Define parameter values used by polyFourierPhaseShiftPrep
freq = 1; % Assumes tfinal = 1 for normalized time
degree = 1; % Include linear term in fit to maximize shape agreement

% Calculate frequency in radians/second
w = 2*pi*freq;

% Calculate cosine and sine harmonic arrays
ncoefs = size(coefs,1);
nharmonics = round((ncoefs-(degree+1))/2);

% Determine length of time vector
npts = size(t,1);

% Calculate y
a = zeros(npts,ncoefs);

a(:,1) = 1.0;
a(:,2) = t;

col = degree+2;

for i = 1:nharmonics
    a(:,col) = cos(i*(w.*t+phi)); % NOT cos(i*w.*t+phi);
    col = col+1;

    a(:,col) = sin(i*(w.*t+phi)); % NOT sin(i*w.*t+phi);
    col = col+1;
end

y = a*coefs;

end
