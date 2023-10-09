% This function is part of the NMSM Pipeline, see file for full license.
%
% This function evaluates a surrogate model using polynomials and
% coefficents. This function is only intended to be used as a saved
% function handle, with one handle saved for each surrogate muscle. The
% polynomials and coefficients belonging to each muscle are stored in the
% handle. 
%
% (2D Array of double, 2D Array of double, Array of symbol, 
% Array of symbol, 2D Array of symbol, 2D Array of double) -> 
% (Array of double, Array of double, 2D Array of double)
%
% Evaluates the surrogate model for a single muscle. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                               %
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

function [muscleTendonLength, muscleTendonVelocity, momentArms] = ...
    evaluateSurrogate(jointAngles, jointVelocities, ...
    polynomialExpressionMuscleTendonLength, ...
    polynomialExpressionMuscleTendonVelocity, ...
    polynomialExpressionMomentArms, coefficients)

% Values are set to match symbolic expressions in polynomials
for i = 1 : size(jointAngles, 2)
    eval(['theta' num2str(i) ' = jointAngles(:,' num2str(i) ');']);
    eval(['thetaDot' num2str(i) ' = jointVelocities(:,' num2str(i) ');']);
end
muscleTendonLengthMatrix = zeros(size(jointAngles, 1), ...
    size(polynomialExpressionMomentArms, 2));
muscleTendonVelocityMatrix = zeros(size(jointVelocities, 1), ...
    size(polynomialExpressionMomentArms, 2));
momentArmsMatrix = zeros(size(jointAngles, 1), size(jointAngles, 2), ...
    size(polynomialExpressionMomentArms, 2));
for j = 1 : size(polynomialExpressionMomentArms, 2)
    muscleTendonLengthMatrix(:, j) = ...
        eval(polynomialExpressionMuscleTendonLength(1, j)) .* ...
        ones(size(jointAngles, 1), 1);
    muscleTendonVelocityMatrix(:, j) = ...
        eval(polynomialExpressionMuscleTendonVelocity(1, j)) .* ...
        ones(size(jointAngles, 1), 1);
    for k = 1 : size(jointAngles, 2)
        momentArmsMatrix(:, k, j) = ...
            eval(polynomialExpressionMomentArms(k, j)) .* ...
            ones(size(jointAngles, 1), 1);
    end                 
end
fullMatrix = [muscleTendonLengthMatrix; muscleTendonVelocityMatrix; ...
    reshape(momentArmsMatrix, [], ...
    size(polynomialExpressionMomentArms, 2))];

modeledValues = fullMatrix * coefficients;
muscleTendonLength = modeledValues(1 : size(jointAngles, 1));
muscleTendonVelocity = modeledValues(1 + size(jointAngles, 1) : ...
    size(jointAngles, 1) * 2);
for i = 1 : size(jointAngles, 2)
    momentArms(:, i) = modeledValues(1 + size(jointAngles, 1) * (1 + i) ...
        : size(jointAngles, 1) * (2 + i));
end
end
