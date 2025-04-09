% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the experimental and
% predicted center of pressure for the specified direction.
%
% (struct, 2D matrix, Array of number, Array of string) -> (Array of number)
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

function [cost, costTerm] = calcTrackingCenterOfPressureIntegrand( ...
    costTerm, inputs, time, modeledValues)
defaultTimeNormalization = true;
[time, costTerm] = normalizeTimeColumn(costTerm, inputs, time, ...
    defaultTimeNormalization);

hindfootBodyName = getTermFieldOrError(costTerm, 'hindfoot_body');
[forces, moments, points, costTerm] = ...
    findGroundReactionsByHindfootBodyName( ...
    costTerm, inputs, modeledValues, hindfootBodyName);
experimentalCenterOfPressure = ...
    findSplinedCenterOfPressureByLabels(costTerm, inputs, time);

centerOfPressure = calcCenterOfPressureForTermAxis( ...
    costTerm, forces, moments, points);

cost = centerOfPressure - experimentalCenterOfPressure;

assert(isfield(costTerm, 'time_ranges'), costTerm.type + " requires " + ...
    "defined <time_ranges> to avoid poorly defined times for the " + ...
    "center of pressure. If this motion has no undefined contact, " + ...
    "use <time_ranges>0 1</time_ranges>.")
[cost, costTerm] = applyTermTimeRanges(cost, costTerm, time);
[cost, costTerm] = applyPercentErrorWithMinimum(cost, ...
    experimentalCenterOfPressure, costTerm);
cost = normalizeCostByFinalTime(costTerm, inputs, time, cost);
end
