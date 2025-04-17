% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the experimental and
% predicted joint angles for the specified coordinate.
%
% (struct, Array of number, 2D matrix, Array of string) -> (Array of number)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [pathConstraint, constraintTerm] = ...
    calcGeneralizedAccelerationSmoothnessDeviationPathConstraint( ...
    constraintTerm, inputs, time, accelerations, coordinateName)
[acceleration, constraintTerm] = findDataByLabels(constraintTerm, accelerations, ...
    inputs.coordinateNames, coordinateName);

polynomialDegree = valueOrAlternate(constraintTerm, "polynomial_degree", 1);
harmonics = valueOrAlternate(constraintTerm, "harmonics", 7);
fit = fitSmoothingTermCurve(inputs, time, acceleration, ...
    polynomialDegree, harmonics);

pathConstraint = acceleration - fit;

[pathConstraint, constraintTerm] = applyTermTimeRanges(pathConstraint, constraintTerm, time);
end
