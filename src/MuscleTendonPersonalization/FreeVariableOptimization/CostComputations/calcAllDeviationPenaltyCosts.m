% This function is part of the NMSM Pipeline, see file for full license.
%
% Cost associated to penalizing differences in activation time constants,
% activation nonlinearity, and EMG scaling factors from user selected set
% point. Additionally, a cost associated to minimizing passive force is
% calculated.
%
% (struct, struct, 3D matrix, struct) -> (struct)
% calculates the cost for changes in paramters from user selected set point

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function cost = calcAllDeviationPenaltyCosts(valuesStruct, ...
    experimentalData, passiveForce, cost)

% Penalize difference of tact from set point
cost.activationTimePenalty = calcPenalizeDifferencesCostTerm( ...
    findCorrectMtpValues(2, valuesStruct) / 100, ...
    experimentalData.errorCenters(2), experimentalData.maxAllowableErrors(2));
% Penalize difference of Anonlin from set point
cost.activationNonlinearityPenalty = calcPenalizeDifferencesCostTerm( ...
    findCorrectMtpValues(3, valuesStruct), experimentalData.errorCenters(3), ...
    experimentalData.maxAllowableErrors(3));
% Penalize difference of lMo values from pre-calibrated values
cost.optimalFiberLengthPenalty = calcPenalizeDifferencesCostTerm( ...
    experimentalData.optimalFiberLength .* ...
    findCorrectMtpValues(6, valuesStruct) - experimentalData.optimalFiberLengthNominal, ...
    experimentalData.errorCenters(4), experimentalData.maxAllowableErrors(4));
% Penalize difference of lTs values from pre-calibrated values
cost.tendonSlackLengthPenalty = calcPenalizeDifferencesCostTerm( ...
    experimentalData.tendonSlackLength .* ...
    findCorrectMtpValues(5, valuesStruct) - experimentalData.tendonSlackLengthNominal, ...
    experimentalData.errorCenters(5), experimentalData.maxAllowableErrors(5));
% Penalize difference of EMGScale from set point
cost.emgScalePenalty = calcPenalizeDifferencesCostTerm( ...
    findCorrectMtpValues(4, valuesStruct), experimentalData.errorCenters(6), ...
    experimentalData.maxAllowableErrors(6));
% Minimize passive force
cost.minPassiveForce = calcPenalizeDifferencesCostTerm(passiveForce, ...
    experimentalData.errorCenters(11), experimentalData.maxAllowableErrors(11));
end

