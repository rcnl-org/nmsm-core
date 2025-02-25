function coefs = polyFourierPhaseShiftCoefs(t,y,nHarmonics)

% This function calculates polyFourier coefficients in preparation for
% phase shifting and tilting the input curve y during an optimization.
% To obtain the best fit, we first fit the curve with a linear polynomial
% term included and then zero out out the coefficient of the linear term,
% keeping only the constant term.
% The input time vector t can contain non-equally spaced time points, while
% the input curve y is assumed to be a near-periodic function.
% This function passes back the final coefficients to be used in another
% function that performs analytical phase shifting of the original curve as
% needed for calculating symmety errors between curves on opposite sides of
% the body (e.g., right and left knee angle curves).
%
% Author: B.J. Fregly
%         January 22, 2025

% Define parameter values for polyFourier fitting
freq = 1; % Assumes tf = 1 for normalized time
degree = 1; % Include linear term in fit to accommodate slightly different
            % first and last points

% Perform poly-Fourier fitting of input curve
coefs = polyFourierCoefs(t,y,freq,degree,nHarmonics);

% Set coefficient of linear term to zero to eliminate differences in first
% and last time point of reconstructed curve
coefs(2,1) = 0;

end
