function coefs = polyFourierCoefs(t,y,f,degree,nharmonics)

% Function to calculate polynomial plus Fourier coefficients
% to fit the specified (t,y) input data.
% Inputs: t - indepdendent variable
%         y - dependent variable
%         f - frequency in Hz
%         degree - polynomial degree (0 through 7)
%         nharmonics - number of Fourier harmonics
% This function assumes that t = tStart to tEnd defines one cycle
% of periodic or nonperiodic data.

% Calculate frequency in radians/second
w = 2*pi*f;

% Allocate memory for linear least squares matrix and vectors.
    
ncoefs = 2*nharmonics+(degree+1);
npts = size(t,1);   % Use last point, even if slightly nonperiodic
time = t(1:npts,1);

A = zeros(npts,ncoefs);
x = zeros(ncoefs,1);
b = zeros(npts,1);
    
% Fill in the first columns of the A matrix based on the polynomial degree.

switch degree

    case 0
        A(:,1) = ones(npts,1);

    case 1
        A(:,1) = ones(npts,1);
        A(:,2) = time;

    case 2
        time2 = time.*time;

        A(:,1) = ones(npts,1);
        A(:,2) = time;
        A(:,3) = time2;

    case 3
        time2 = time.*time;
        time3 = time2.*time;

        A(:,1) = ones(npts,1);
        A(:,2) = time;
        A(:,3) = time2;
        A(:,4) = time3;

    case 4
        time2 = time.*time;
        time3 = time2.*time;
        time4 = time3.*time;

        A(:,1) = ones(npts,1);
        A(:,2) = time;
        A(:,3) = time2;
        A(:,4) = time3;
        A(:,5) = time4;

    case 5
        time2 = time.*time;
        time3 = time2.*time;
        time4 = time3.*time;
        time5 = time4.*time;

        A(:,1) = ones(npts,1);
        A(:,2) = time;
        A(:,3) = time2;
        A(:,4) = time3;
        A(:,5) = time4;
        A(:,6) = time5;

    case 6
        time2 = time.*time;
        time3 = time2.*time;
        time4 = time3.*time;
        time5 = time4.*time;
        time6 = time5.*time;

        A(:,1) = ones(npts,1);
        A(:,2) = time;
        A(:,3) = time2;
        A(:,4) = time3;
        A(:,5) = time4;
        A(:,6) = time5;
        A(:,7) = time6;

    case 7
        time2 = time.*time;
        time3 = time2.*time;
        time4 = time3.*time;
        time5 = time4.*time;
        time6 = time5.*time;
        time7 = time6.*time;

        A(:,1) = ones(npts,1);
        A(:,2) = time;
        A(:,3) = time2;
        A(:,4) = time3;
        A(:,5) = time4;
        A(:,6) = time5;
        A(:,7) = time6;
        A(:,8) = time7; 

    otherwise
        disp('Illegal polynomial degree')

end
    
% Fill in the remaining columns of the A matrix with harmonics one at a
% time.

col = degree+2;

for i = 1:nharmonics
    A(:,col) = cos(i*w*time);
    col = col+1;

    A(:,col) = sin(i*w*time);
    col = col+1;
end
    
% Fill in the b vector with data.

b = y(1:npts,1);

% Solve for the unknown coefficients via linear least squares.

x = A\b;
    
% Assign output polynomial and Fourier coefficients.

coefs = x;

end
