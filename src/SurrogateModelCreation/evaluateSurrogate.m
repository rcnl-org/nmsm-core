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

function [muscleTendonLength, muscleTendonVelocity, momentArms] = ...
    evaluateSurrogate(jointAngles, jointVelocities, ...
    polynomialExpressionMuscleTendonLength, ...
    polynomialExpressionMuscleTendonVelocity, ...
    polynomialExpressionMomentArms, coefficients)

muscleTendonLength = zeros(size(jointAngles, 1), 1);
muscleTendonVelocity = zeros(size(jointAngles, 1), 1);
momentArms = zeros(size(jointAngles)).';

for i = 1 : size(jointAngles, 1)
    positionArgs = num2cell(jointAngles(i, :));
    velocityArgs = [positionArgs num2cell(jointVelocities(i, :))];
    muscleTendonLength(i) = polynomialExpressionMuscleTendonLength(positionArgs{:}) * coefficients;
    muscleTendonVelocity(i) = polynomialExpressionMuscleTendonVelocity(velocityArgs{:}) * coefficients;
    momentArms(:, i) = polynomialExpressionMomentArms(positionArgs{:}) * coefficients;
end

momentArms = momentArms.';
end
