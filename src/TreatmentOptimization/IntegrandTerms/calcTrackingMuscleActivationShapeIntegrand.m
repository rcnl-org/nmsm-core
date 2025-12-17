% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the experimental and
% predicted muscle activations for the specified muscle with free scaling.
%
% (2D matrix, Array of number, struct, Array of string) -> (Array of number)
%

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

function [cost, costTerm] = calcTrackingMuscleActivationShapeIntegrand(costTerm, ...
    muscleActivations, time, inputs, muscleName)
defaultTimeNormalization = true;
[time, costTerm] = normalizeTimeColumn(costTerm, inputs, time, ...
    defaultTimeNormalization);

[activation, costTerm] = findDataByLabels(costTerm, muscleActivations, ...
    inputs.muscleNames, muscleName);
experimentalActivation = findSplinedMuscleActivationsByLabels(costTerm, ...
    inputs, time);

scaleFactor = activation \ experimentalActivation;
cost = experimentalActivation - (activation * scaleFactor);

cost = normalizeCostByFinalTime(costTerm, inputs, time, cost);
end
