% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses symbolic polynomial expressions to approximate 
% muscle tendon lengths and moment arms
%
% Inputs:
% params.polynomialExpressionMuscleTendonLengths (1 x numberOfMuscles)
% params.polyninomialExpressionMomentArms (1 x numberOfMuscles)
% params.coefficients (1 x numberOfMuscles)
% params.dofsActuated (numberOfCoordinates x numberOfMuscles)
% jointAngles (1 x numberOfMuscles)
%
% (Symbol cell array, Symbol cell array, Number cell array, 
% Number cell array) -> (2D Number array, Number cell array)
%
% returns estimated muscle tendon lengths and moment arms 

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
% -----------------------------------------------------------------------

function [newMuscleTendonLengths, newMomentArms, ...
    newMuscleTendonVelocities] = calcSurrogateModel(inputs, jointAngles, ...
    jointVelocities)
persistent indexMatrix;
if isa(jointAngles{1}, 'casadi.MX')
    newMuscleTendonLengths = casadi.MX.zeros(size(jointAngles{1}, 1), ...
        size(jointAngles, 2));
    newMuscleTendonVelocities = casadi.MX.zeros(size(jointAngles{1}, 1),...
        size(jointAngles, 2));
    newMomentArms = casadi.MX.zeros(size(jointAngles{1}, 1), ...
        length(inputs.coordinateNames) * size(jointAngles, 2));
else
    newMuscleTendonLengths = zeros(size(jointAngles{1}, 1), ...
        size(jointAngles, 2));
    newMuscleTendonVelocities = zeros(size(jointAngles{1}, 1), ...
        size(jointAngles, 2));
    newMomentArms = zeros(size(jointAngles{1}, 1), ...
        length(inputs.coordinateNames), size(jointAngles, 2));
end
if isempty(indexMatrix)
    indexMatrix = cell(1, size(jointAngles, 2));
    for i = 1 : size(jointAngles, 2)
        indexMatrix{i} = zeros(0, 2);
        index = 1;
        for j = 1 : length(inputs.coordinateNames)
            for k = 1 : length(inputs.surrogateModelLabels{i})
                if strcmp(inputs.coordinateNamesStrings(j), inputs.surrogateModelLabels{i}(k))
                    indexMatrix{i}(end+1, :) = [j, index];
                    index = index + 1;
                end
            end
        end
    end
end
for i = 1 : size(jointAngles, 2)
    [newMuscleTendonLengths(:, i), newMuscleTendonVelocities(:, i), ...
        momentArms] = inputs.surrogateMuscles{i}(jointAngles{i}, ...
        jointVelocities{i}, inputs.surrogateMusclesNumArgs);
    for j = 1 : size(indexMatrix{i}, 1)
        if isa(jointAngles{1}, 'casadi.MX')
            newMomentArms(:, indexMatrix{i}(j, 1) + ...
                length(inputs.coordinateNames) * (i - 1)) = ...
                momentArms(:, indexMatrix{i}(j, 2));
        else
            newMomentArms(:, indexMatrix{i}(j, 1), i) = ...
                momentArms(:, indexMatrix{i}(j, 2));
        end
    end
end
end
