function [qFit,qpFit,qppFit] = BsplineFit(time,q,degree,numNodes)

% Create B-spline matrices for specified spline degree, number of B-spline
% nodes, and number of data points.
numPts = length(time);
interval = time(2)-time(1);
[N, Np, Npp] = BSplineMatrices(degree,numNodes,numPts,interval);
% [N] = BSplineMatrix(degree,numNodes,numPts);
% Note that the interval setting is only needed to calculate first and
% second derivatives correctly.

% Calculate B-spline nodes that best fit the original curve using linear
% least squares.
Nodes = N\q;

% Now reconstruct the parameterized curve and its first and second
% derivatives using the calculated B-spline matrices and nodes.
qFit = N*Nodes;
qpFit = Np*Nodes;
qppFit = Npp*Nodes;
