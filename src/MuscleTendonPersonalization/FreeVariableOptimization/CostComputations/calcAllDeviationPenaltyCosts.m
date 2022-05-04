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
    inputData, passiveForce, cost)

% Penalize difference of tact from set point
cost.activationTimePenalty = calcPenalizeDifferencesCostTerm( ...
    findCorrectMtpValues(2, valuesStruct) / 100, ...
    inputData.errorCenters(2), inputData.maxAllowableErrors(2));
% Penalize difference of Anonlin from set point
cost.activationNonlinearityPenalty = calcPenalizeDifferencesCostTerm( ...
    findCorrectMtpValues(3, valuesStruct), inputData.errorCenters(3), ...
    inputData.maxAllowableErrors(3));
% Penalize difference of lMo values from pre-calibrated values
cost.optimalFiberLengthPenalty = calcPenalizeDifferencesCostTerm( ...
    inputData.optimalFiberLength .* ...
    findCorrectMtpValues(6, valuesStruct) - inputData.optimalFiberLengthNominal, ...
    inputData.errorCenters(4), inputData.maxAllowableErrors(4));
% Penalize difference of lTs values from pre-calibrated values
cost.tendonSlackLengthPenalty = calcPenalizeDifferencesCostTerm( ...
    inputData.tendonSlackLength .* ...
    findCorrectMtpValues(5, valuesStruct) - inputData.tendonSlackLengthNominal, ...
    inputData.errorCenters(5), inputData.maxAllowableErrors(5));
% Penalize difference of EMGScale from set point
cost.emgScalePenalty = calcPenalizeDifferencesCostTerm( ...
    findCorrectMtpValues(4, valuesStruct), inputData.errorCenters(6), ...
    inputData.maxAllowableErrors(6));
% Minimize passive force
cost.minPassiveForce = calcPenalizeDifferencesCostTerm(passiveForce, ...
    inputData.errorCenters(11), inputData.maxAllowableErrors(11));
end

