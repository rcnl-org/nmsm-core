% This function is part of the NMSM Pipeline, see file for full license.
%
% This function fits muscle tendon lengths and moment arms as a 
% function of joint angles for all muscles
%
% Inputs:
% jointAngles (numberFrames x degreesOfFreedom)
% muscleTendonLengths (numberFrames x 1)
% momentArms (numberFrames x degreesOfFreedom)
% polynomialDegree (value)
%
% (2D Number matrix, Number array, 2D Number matrix, Number) -> 
% (Symbol array, 2D Symbol array, Number array)
%
% returns polynomial expressions with corresponding coefficients that
% best fit experimental muscle tendon lengths and moment arms for all 
% muscles.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Spencer Williams                               %
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

function [surrogateMuscles, numArgs] = createSurrogateModel(jointAngles, ...
    muscleTendonLengths, momentArms, polynomialDegree)
surrogateMuscles = cell(1, size(muscleTendonLengths, 2));
numArgs = ones(1, size(muscleTendonLengths, 2) * 3);
parallelLengths = cell(1, size(muscleTendonLengths, 2));
parallelVelocities = cell(1, size(muscleTendonLengths, 2));
parallelMomentArms = cell(1, size(muscleTendonLengths, 2));
coefficients = cell(1, size(muscleTendonLengths, 2));
% Create surorogate model for all muscles
parfor i = 1 : size(muscleTendonLengths, 2)
    [polynomialExpressionMuscleTendonLengths, ...
        polynomialExpressionMuscleTendonVelocities, ...
        polynomialExpressionMomentArms, coefficients{i}] = ...
        createMuscleSpecificSurrogateModel(jointAngles{i}, ...
        muscleTendonLengths(:, i), momentArms{i}, polynomialDegree);

    parallelLengths{i} = matlabFunction(polynomialExpressionMuscleTendonLengths);
    parallelVelocities{i} = matlabFunction(polynomialExpressionMuscleTendonVelocities);
    parallelMomentArms{i} = matlabFunction(polynomialExpressionMomentArms);
end
for i = 1 : size(muscleTendonLengths, 2)
    polynomialMuscleTendonLengths = str2func(func2str(parallelLengths{i}));
    polynomialMuscleTendonVelocities = str2func(func2str(parallelVelocities{i}));
    polynomialMomentArms = str2func(func2str(parallelMomentArms{i}));

    numArgs(i * 3 - 2) = nargin(polynomialMuscleTendonLengths);
    numArgs(i * 3 - 1) = nargin(polynomialMuscleTendonVelocities);
    numArgs(i * 3) = nargin(polynomialMomentArms);

    surrogateMuscles{i} = @(jointAngles, jointVelocities, numArgs)evaluateSurrogate( ...
        jointAngles, jointVelocities, ...
        polynomialMuscleTendonLengths, ...
        polynomialMuscleTendonVelocities, ...
        polynomialMomentArms, coefficients{i}, numArgs(i * 3 - 2 : i * 3));
end
end
