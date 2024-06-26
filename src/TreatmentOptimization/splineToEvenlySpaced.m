% This function is part of the NMSM Pipeline, see file for full license.
%
% makeStateDerivatives() requires evenly spaced points for the b-spline
% derivatives. This function should be used to make the points evenly
% spaced via splining
%
% (struct, struct) -> (None)
% Splines results to make them evenly spaced

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

function [newTime, newData] = splineToEvenlySpaced(time, data, ...
    numPoints)
newTime = time;
newData = data;
% gcvSplineSet = makeGcvSplineSet(time(1 : end - 1), ...
%     data(1 : end - 1, :), string(1:size(data, 2)));
% newTime = linspace(time(1), time(end), numPoints);
% newData = evaluateGcvSplines( gcvSplineSet, string(1:size(data, 2)), ...
%     newTime, 0);
end

