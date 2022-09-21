function [nodes] = BsplineNodes(time,q,degree,numNodes)

% Construct B-spline nodes for specified time vector, spline degree, and
% number of B-spline nodes, assuming the initial curve to be fitted is
% a zero vector of the same length as the time vector.
numPts = length(time);
interval = time(2)-time(1);
[N,~,~] = BSplineMatrices(degree,numNodes,numPts,interval);
% [N] = BSplineMatrix(degree,numNodes,numPts);
% Note that the interval setting is only needed to calculate first and
% second derivatives correctly.

% Calculate B-spline nodes that best fit the original curve using linear
% least squares.
nodes = N\q;

end
