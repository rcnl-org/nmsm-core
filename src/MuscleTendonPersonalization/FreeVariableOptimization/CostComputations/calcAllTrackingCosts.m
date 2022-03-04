% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (struct, struct, array of number, array of number) -> (number)
% calculates the cost of penalizing paired muscle separation

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

function cost = calcAllTrackingCosts(valuesStruct, params, ...
    modelMoments, lMtilda)
% Minimize joint moment tracking errors
cost.momentMatching = calcTrackingCostTerm(modelMoments, ...
    params.experimentalMoments, params.errorCenters(1), ...
    params.maxAllowableErrors(1));
% Penalize difference of lMo values from pre-calibrated values
cost.lMoPenalty = calcTrackingCostTerm(findCorrectValues(5, ...
    valuesStruct), params.lMoNominal, params.errorCenters(4), ...
    params.maxAllowableErrors(4));
% Penalize difference of lTs values from pre-calibrated values
cost.lTsPenalty = calcTrackingCostTerm(findCorrectValues(6, ...
    valuesStruct), params.lTsNominal, params.errorCenters(5), ...
    params.maxAllowableErrors(5));
% Penalize change of lMtilda from pre-calibrated values
costlMtildaMeanPenalty = calcTrackingCostTerm(permute(mean(lMtilda, 2), ...
    [1 3 2]), permute(mean(params.lMtildaExprimental,2),[1 3 2]), ...
    params.errorCenters(7), params.maxAllowableErrors(7));
costlMtildaShapePenalty = calcTrackingCostTerm( ...
    calcMeanDifference1D(compress3dMatrixTo2d(lMtilda)), ...
    calcMeanDifference1D(compress3dMatrixTo2d( ...
    params.lMtildaExprimental)), params.errorCenters(7), ...
    params.maxAllowableErrors(7));
cost.lMtildaPenalty = [costlMtildaMeanPenalty; costlMtildaShapePenalty];
end

