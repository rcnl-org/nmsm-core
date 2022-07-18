% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses GCVSplines from OpenSim to calculate the derivative of
% each column and returns an array of the same shape as provided.
%
% (Array of double, 2D array of double) => (2D array of double)
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

function derivative = calcDerivative(time, data)
verifyTrue(length(time)==size(data, 2), ...
    "time and data arrays are not of correct shape.");
gcvSplines = {};
for i=1:size(data, 1)
    gcvSplines{i} = org.opensim.modeling.GCVSpline();
    gcvSplines{i}.setDegree(7);
end
for i=1:length(time)
    for j=1:size(data, 1)
        gcvSplines{j}.addPoint(time(i), data(j, i));
    end
end
derivative = zeros(size(data));
setting = org.opensim.modeling.StdVectorInt([0]);
for i=1:length(time)
    for j=1:size(data, 1)
        timeVector = org.opensim.modeling.Vector.createFromMat([time(i)]);
        pointDerivative = gcvSplines{j}.calcDerivative(setting, timeVector);
        derivative(j, i) = pointDerivative;
    end
end
end
