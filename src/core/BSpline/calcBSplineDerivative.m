% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses BSplines to calculate the derivative of
% each column and returns an array of the same shape as provided.
%
% (double array, 2D double array, integer, integer) => (2D array of double)
% Returns the derivative of each column provided

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function derivative = calcBSplineDerivative(time, data, degree, numNodes)
if ~((length(time)==size(data, 2))||(length(time)==size(data, 1)))
    error("time and data arrays are not of correct shape.");
end

numPts = length(time);
interval = time(2)-time(1);
[N, Np, ~] = BSplineMatrices(degree,numNodes,numPts,interval);

newData = data;
if length(time)==size(newData, 2)
newData = newData';
end

Nodes = N\newData;
derivative = Np*Nodes;

if size(data, 1)~=size(derivative, 1)
derivative = derivative';
end

end
