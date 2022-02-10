% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (array of number, array of string) -> (array of number)
% calculates the cost of differences in EMG pairs

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

function [lmtildaMeanSimilarityError, lmtildaShapeSimilarityError] = ...
    calcChangesInNormalizedMuscleFiberLengthCurves(lMtilda, ...
    lMtildaExprimental, lmtildaPairs)

% Penalize violation of lMtilda similarity between paired muscles
Ind = 1;
for i = 1:length(lmtildaPairs)
    % original distance of mean value of each lMtilda from the mean of all
    % lMtilda curves
    distMeanlmtildaOrigSimilarity = calcMeanDifference2D(mean( ...
        compress3dMatrixTo2d(lMtildaExprimental(:, :, lmtildaPairs{i})),1));
    % Distance of mean value of each lMtilda from the mean of all original
    % lMtilda curves
    distMeanlmtildaSimilarity = mean(compress3dMatrixTo2d(lMtilda(:, :, ...
        lmtildaPairs{i})), 1) - mean(mean(compress3dMatrixTo2d( ...
        lMtildaExprimental(:, :, lmtildaPairs{i}))));
    % Penalize the change between new and original distances
    lmtildaMeanSimilarityError(Ind:Ind + size(lmtildaPairs{i}, 2) - 1) = ...
        calcMeanDifference2D(distMeanlmtildaSimilarity - ...
        distMeanlmtildaOrigSimilarity);
    lmtildaShape = calcMeanDifference1D(compress3dMatrixTo2d(lMtilda(:, ...
        :, lmtildaPairs{i})));
    lmtildaShapeSimilarityError(:, Ind:Ind + size(lmtildaPairs{i}, 2) - 1) ...
        = calcMeanDifference2D(lmtildaShape);
    Ind = Ind + size(lmtildaPairs{i}, 2);
end
end

