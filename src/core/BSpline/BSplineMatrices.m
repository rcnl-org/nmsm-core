% This function is part of the NMSM Pipeline, see file for full license.
%
% Generates the matrices necessary to create a B-spline curve and its 
% first and second time derivative given the B-spline degree, number of 
% nodes, number of output time frames, and sampling interval.
% 
% (double, double, double, double) 
% -> (Array of double, Array of double, Array of double)
% Generates B-spline matrices to represent data and two derivatives. 

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

function [N_matrix, Np_matrix, Npp_matrix] = BSplineMatrices(Degree, Nodes, Frames, Interval)
% Check to see which input arguments should be set to default values.
if nargin ~= 4
    fprintf('Error in function BSplineMatrices: Too few input arguments.\n')
    N_matrix = [];
    Np_matrix = [];
    Npp_matrix = [];
    return
end

% Increase number of time frames by 4 to pad front and back by 2 time
% frames each as needed to produce accurate first and second derivative
% results.
Frames = Frames+4;

% Define time vector for chosen number of time frames.
XTrue = linspace(0, (Interval)*(Frames-1), Frames)';

% Create input control points.
XIn = linspace(0, (Interval)*(Frames-1), Nodes)';

% Define the number of control points.
numberPoints = size(XIn, 1);

% Check if the degree of the curve is greater than number of control points
% minus one.
if Degree > (numberPoints-1)
    error(sprintf('Error: the maximum degree of the B-spline cannot exceed %d', numberPoints-1));
end

% Define the parameters n (allowing indices to start at zero for n+1
% control points) and d (controlling degree of polynomial in u and curve
% continuity).
n = numberPoints - 1;
d = Degree + 1;

% Define parametric knots (or knot values) Uj for open curve B-spline,
% which relate the parametric variable u to the Pj control points.
for tempJ = 1:(n + d + 1)
    j = tempJ - 1;
    if j < d
        Uj(tempJ) = 0;
    elseif j >= d & j <= n
        Uj(tempJ) = j - d + 1;
    elseif j > n
        Uj(tempJ) = n - d + 2;
    end
end

Ujmax = max(Uj);
tf = XTrue(end,1);
Uj = Uj * (tf/Ujmax);

% Define the range of the parametric variable u.
umax = n - d + 2;
u_range = 0:(umax/(Frames-1)):umax;

u_range = u_range * (tf/umax);
umax = tf;

% Allocate memory for the B-spline basis blending functions N (a weighting
% function).
N = zeros(1, (n + d));

% Instantiate the N matrix for the shape functions.
N_matrix = [];

% Loop through the entire range of the parametric variable u.
for u = u_range

    % Loop through each normalized polynomial degree in u.
    for k = 1:d

        % Check if the normalized polynomial degree in u is equal to one.
        if k == 1

            % Loop through each parametric knot (or knot values).
            tol = 1e-12; % Original default was 1e-8

            for i = 1:numberPoints

                % Calculate the first order basis functions.
                if (u >= Uj(i)) & (u < Uj(i+1))
                    N(i) = 1;
                elseif (abs(u - umax) < tol) & (abs(u - Uj(i) - (tf/Ujmax)) < tol) & (u - Uj(i+1) <= tol),
                    N(i) = 1;
                else
                    N(i) = 0;
                end

            end	% End loop through each parametric knot (or knot values).

        % Otherwise if the normalized polynomial degree in u is not equal
        % to one.
        else

            % Loop through each parametric knot (or knot values).
            for i = 1:numberPoints

                % Calculate the higher order basis functions.
                if ((Uj(i+k-1) - Uj(i)) == 0) & ((Uj(i+k) - Uj(i+1)) == 0)
                    N(i) = 0;
                elseif ((Uj(i+k-1) - Uj(i)) == 0) & ((Uj(i+k) - Uj(i+1)) ~= 0)
                    N(i) = ((Uj(i+k) - u)*N(i+1)) / (Uj(k+i) - Uj(i+1));
                elseif ((Uj(i+k-1) - Uj(i)) ~= 0) & ((Uj(i+k) - Uj(i+1)) == 0)
                    N(i) = ((u - Uj(i))*N(i)) / (Uj(i+k-1) - Uj(i));
                else
                    N(i) = ((u - Uj(i))*N(i) / (Uj(i+k-1) - Uj(i))) + ((Uj(i+k) - u)*N(i+1) / (Uj(k+i) - Uj(i+1)));
                end

            end % End loop through each parametric knot (or knot values).

        end % End check if the normalized polynomial degree in u is equal to one or not.

    end % End of for loop through each polynomial degree in u.

    % Compile all time frames of the shape functions.
    N_matrix = [N_matrix; N(1, 1:numberPoints)];

end % End of for loop through the entire range of the parametric variable u.

% Compute first derivative matrix and output points.
% [Fx, Np_matrix] = gradient(N_matrix, XTrue, XTrue);
[Fx, Np_matrix] = gradient(N_matrix, Interval, Interval);

% Compute second derivative matrix and output points.
% [Fxx, Npp_matrix] = gradient(Np_matrix, XTrue, XTrue);
[Fxx, Npp_matrix] = gradient(Np_matrix, Interval, Interval);

% Note that given node values stored in column matrix YNodes,
% corresponding output points Y and their first and second derivatives
% Yp and Ypp, respectively, are calculated easily as follows:
% Y = N_matrix*YNodes;
% Yp = Np_matrix*YNodes;
% Ypp = Npp_matrix*YNodes;

% Trim first and last two rows off N, Np, and Npp matrices so that these
% matrices will calculate output points only over the desired time range.
N_matrix = N_matrix(3:Frames-2,:);
Np_matrix = Np_matrix(3:Frames-2,:);
Npp_matrix = Npp_matrix(3:Frames-2,:);

% Save N matrix and its first and second derivatives for future
% applications.
% save(['N_order' num2str(Degree) '_nodes' num2str(Nodes) '_points' num2str(Frames) '_matrix.txt'], 'N_matrix', '-ascii', '-double')
% save(['Np_order' num2str(Degree) '_nodes' num2str(Nodes) '_points' num2str(Frames) '_matrix.txt'], 'Np_matrix', '-ascii', '-double')
% save(['Npp_order' num2str(Degree) '_nodes' num2str(Nodes) '_points' num2str(Frames) '_matrix.txt'], 'Npp_matrix', '-ascii', '-double')

