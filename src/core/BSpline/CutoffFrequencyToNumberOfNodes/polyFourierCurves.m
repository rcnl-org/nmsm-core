function fit = polyFourierCurves(coefs,f,t,degree,derivs)

% Function to compute up to 7th degree polynomial plus Fourier
% fitted values given the pre-computed polynomial and Fourier
% coefficients saved in a column vector. This function is
% intended to be vectorized.

% Calculate frequency in radians/second
w = 2*pi*f;

% Calculate cosine and sine harmonic arrays

ncoefs = size(coefs,1);
nharmonics = (ncoefs-(degree+1))/2;

npts = size(t,1);

% Calculate y

a = zeros(npts,ncoefs);

switch degree

    case 0
        a(:,1) = 1.0;

    case 1
        a(:,1) = 1.0;
        a(:,2) = t;

    case 2
        t2 = t.*t;

        a(:,1) = 1.0;
        a(:,2) = t;
        a(:,3) = t2;

    case 3
        t2 = t.*t;
        t3 = t2.*t;

        a(:,1) = 1.0;
        a(:,2) = t;
        a(:,3) = t2;
        a(:,4) = t3;

    case 4
        t2 = t.*t;
        t3 = t2.*t;
        t4 = t3.*t;

        a(:,1) = 1.0;
        a(:,2) = t;
        a(:,3) = t2;
        a(:,4) = t3;
        a(:,5) = t4;

    case 5
        t2 = t.*t;
        t3 = t2.*t;
        t4 = t3.*t;
        t5 = t4.*t;

        a(:,1) = 1.0;
        a(:,2) = t;
        a(:,3) = t2;
        a(:,4) = t3;
        a(:,5) = t4;
        a(:,6) = t5;

    case 6
        t2 = t.*t;
        t3 = t2.*t;
        t4 = t3.*t;
        t5 = t4.*t;
        t6 = t5.*t;

        a(:,1) = 1.0;
        a(:,2) = t;
        a(:,3) = t2;
        a(:,4) = t3;
        a(:,5) = t4;
        a(:,6) = t5; 
        a(:,7) = t6; 

    case 7
        t2 = t.*t;
        t3 = t2.*t;
        t4 = t3.*t;
        t5 = t4.*t;
        t6 = t5.*t;
        t7 = t6.*t;

        a(:,1) = 1.0;
        a(:,2) = t;
        a(:,3) = t2;
        a(:,4) = t3;
        a(:,5) = t4;
        a(:,6) = t5; 
        a(:,7) = t6; 
        a(:,8) = t7; 

    otherwise
        disp('Illegal polynomial degree')

end

col = degree+2;

for i = 1:nharmonics
    iw = i*w;

    a(:,col) = cos(iw.*t);
    col = col+1;

    a(:,col) = sin(iw.*t);
    col = col+1;
end

y = a*coefs;

% Check derivatives flag

if ~derivs
    fit = y;
    return;
end

% Calculate yp

ap = zeros(npts,ncoefs);

switch degree

    case 0
        ap(:,1) = 0.0;

    case 1
        ap(:,1) = 0.0;
        ap(:,2) = 1;

    case 2
        ap(:,1) = 0.0;
        ap(:,2) = 1;
        ap(:,3) = 2*t;

    case 3
        ap(:,1) = 0.0;
        ap(:,2) = 1;
        ap(:,3) = 2*t;
        ap(:,4) = 3*t2;

    case 4
        ap(:,1) = 0.0;
        ap(:,2) = 1;
        ap(:,3) = 2*t;
        ap(:,4) = 3*t2;
        ap(:,5) = 4*t3;

    case 5
        ap(:,1) = 0.0;
        ap(:,2) = 1;
        ap(:,3) = 2*t;
        ap(:,4) = 3*t2;
        ap(:,5) = 4*t3;
        ap(:,6) = 5*t4;

    case 6
        ap(:,1) = 0.0;
        ap(:,2) = 1;
        ap(:,3) = 2*t;
        ap(:,4) = 3*t2;
        ap(:,5) = 4*t3;
        ap(:,6) = 5*t4;
        ap(:,7) = 6*t5;

    case 7
        ap(:,1) = 0.0;
        ap(:,2) = 1;
        ap(:,3) = 2*t;
        ap(:,4) = 3*t2;
        ap(:,5) = 4*t3;
        ap(:,6) = 5*t4;
        ap(:,7) = 6*t5; 
        ap(:,8) = 7*t6; 

    otherwise
        disp('Illegal polynomial degree')

end

col = degree+2;

for i = 1:nharmonics
    iw = i*w;

    ap(:,col) = -iw*sin(iw.*t);
    col = col+1;

    ap(:,col) = iw*cos(iw.*t);
    col = col+1;
end

yp = ap*coefs;

% Calculate ypp

app = zeros(npts,ncoefs);

switch degree

    case 0
        app(:,1) = 0.0;

    case 1
        app(:,1) = 0.0;
        app(:,2) = 0.0;

    case 2
        app(:,1) = 0.0;
        app(:,2) = 0.0;
        app(:,3) = 2;

    case 3
        app(:,1) = 0.0;
        app(:,2) = 0.0;
        app(:,3) = 2;
        app(:,4) = 6*t;

    case 4
        app(:,1) = 0.0;
        app(:,2) = 0.0;
        app(:,3) = 2;
        app(:,4) = 6*t;
        app(:,5) = 12*t2;

    case 5
        app(:,1) = 0.0;
        app(:,2) = 0.0;
        app(:,3) = 2;
        app(:,4) = 6*t;
        app(:,5) = 12*t2;
        app(:,6) = 20*t3;

    case 6
        app(:,1) = 0.0;
        app(:,2) = 0.0;
        app(:,3) = 2;
        app(:,4) = 6*t;
        app(:,5) = 12*t2;
        app(:,6) = 20*t3;
        app(:,7) = 30*t3;

    case 7
        app(:,1) = 0.0;
        app(:,2) = 0.0;
        app(:,3) = 2;
        app(:,4) = 6*t;
        app(:,5) = 12*t2;
        app(:,6) = 20*t3;
        app(:,7) = 30*t3;
        app(:,8) = 42*t3; 

    otherwise
        disp('Illegal polynomial degree')

end

col = degree+2;

w2 = w*w;

for i = 1:nharmonics
    iw = i*w;
    i2 = i*i;
    i2w2 = i2*w2;

    app(:,col) = -i2w2*cos(iw.*t);
    col = col+1;

    app(:,col) = -i2w2*sin(iw.*t);
    col = col+1;
end

ypp = app*coefs;

% Store results

fit = [y yp ypp];

end