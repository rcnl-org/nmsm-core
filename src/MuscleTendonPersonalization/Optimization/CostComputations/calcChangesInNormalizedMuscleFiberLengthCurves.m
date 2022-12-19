% This function is part of the NMSM Pipeline, see file for full license.
%
% The mean and shape of grouped lmtilda curves are calculated. 
%
% (struct, array of string, struct) -> (number)
% calculates differences between grouped lmtilda curve shapes and means. 

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

function [normalizedFiberLengthMagnitudeDeviation, ...
    normalizedFiberLengthShapeDeviation] = ...
    calcChangesInNormalizedMuscleFiberLengthCurves( ...
    modeledNormalizedFiberLength, experimentalNormalizedFiberLength, ...
    normalizedFiberLengthGroups)

% Penalize violation of lMtilda similarity between grouped muscles
Ind = 1;
for i = 1:length(normalizedFiberLengthGroups)
    % original distance of mean value of each lMtilda from the mean of all
    % lMtilda curves
    distMeanlmtildaOrigSimilarity = calcMeanDifference2D(mean( ...
        compress3dMatrixTo2d(experimentalNormalizedFiberLength(:, :, normalizedFiberLengthGroups{i})), 1));
    % Distance of mean value of each lMtilda from the mean of all original
    % lMtilda curves
    distMeanlmtildaSimilarity = mean(compress3dMatrixTo2d(lMtilda(:, :, ...
        normalizedFiberLengthGroups{i})), 1) - mean(mean(compress3dMatrixTo2d( ...
        experimentalNormalizedFiberLength(:, :, normalizedFiberLengthGroups{i}))));
    % Penalize the change between new and original distances
    normalizedFiberLengthMagnitudeDeviation(Ind:Ind + size(normalizedFiberLengthGroups{i}, 2) - 1) = ...
        calcMeanDifference2D(distMeanlmtildaSimilarity - ...
        distMeanlmtildaOrigSimilarity);
    lmtildaShape = calcMeanDifference1D(compress3dMatrixTo2d(lMtilda(:, ...
        :, normalizedFiberLengthGroups{i})));
    normalizedFiberLengthShapeDeviation(:, Ind:Ind + size(normalizedFiberLengthGroups{i}, 2) - 1) ...
        = calcMeanDifference2D(lmtildaShape);
    Ind = Ind + size(normalizedFiberLengthGroups{i}, 2);
end
end

