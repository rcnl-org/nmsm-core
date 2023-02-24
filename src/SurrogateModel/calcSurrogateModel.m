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
% Author(s): Marleny Vega                                                 %
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

function [newMuscleTendonLengths, newMomentArms] = calcSurrogateModel( ...
    params, jointAngles)

for i = 1 : size(jointAngles, 2)
    % Initialize symbolic thetas
%     theta = sym('theta', [1 size(jointAngles{i}, 2)]);
    % Get A matrix
    matrix = PatientSpecificSurrogateModel(jointAngles{i},i);
%     matrix = getDataMatrixEqn(params.polynomialExpressionMuscleTendonLengths{i}, ...
%         params.polynomialExpressionMomentArms{i}, jointAngles{i}, theta);
    % Caculate new muscle tendon lengths and moment arms
    vector = matrix * params.coefficients{i};
    newMuscleTendonLengths(:, i) = vector(1 : size(jointAngles{i}, 1));
    index = 1;
    for j = 1 : size(params.dofsActuated, 1)
        if params.dofsActuated(j, i) > params.epsilon
            newMomentArms(:, j, i) = vector(size(jointAngles{i}, 1) * ...
                index + 1 : size(jointAngles{i}, 1) * (index + 1));
            index = index + 1;
        else
            newMomentArms(:, j, i) = zeros(size(jointAngles{i}, 1), 1);
        end
    end
end
end