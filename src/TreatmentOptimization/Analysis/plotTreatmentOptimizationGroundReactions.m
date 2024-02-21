% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads two .sto files: 1) experimental ground reactions, and 
% 2) model ground reactions, and plots them. There are 2 optional arguments 
% for figure width and figure height. If no optional arguments are given, 
% the figure size is automatically adjusted to fit all data on one plot. 
% Giving just figure width imposes the width and fits the height to fit on 
% one plot. Giving both arguments will impose both figure height and width, 
% and create multiple plots as needed.
%
% (string) -> (None)
% Plot joint moment curves from file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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
function plotTreatmentOptimizationGroundReactions(experimentalGroundReactionFile, ...
    modelGroundReactionFile, figureWidth, figureHeight)

import org.opensim.modeling.Storage
experimentalGRStorage = Storage(experimentalGroundReactionFile);
experimentalLabels = getStorageColumnNames(experimentalGRStorage);
experimentalGR = storageToDoubleMatrix(experimentalGRStorage)';
experimentalTime = findTimeColumn(experimentalGRStorage);
if experimentalTime(1) ~= 0
    experimentalTime = experimentalTime - experimentalTime(1);
end
modelGRStorage = Storage(modelGroundReactionFile);
modelLabels = getStorageColumnNames(modelGRStorage);
modelGR = storageToDoubleMatrix(modelGRStorage)';
modelTime = findTimeColumn(modelGRStorage);
if modelTime(1) ~= 0
    modelTime = modelTime - modelTime(1);
end

% Check both GR files are in the same order.
experimentalForcePlate1 = contains(experimentalLabels, "1");
modelForcePlate1 = contains(modelLabels, "1");
if experimentalForcePlate1 ~= modelForcePlate1
    temp = modelGR;
    modelGR(:, ~experimentalForcePlate1) = modelGR(:, experimentalForcePlate1);
    modelGR(:, experimentalForcePlate1) = temp(:, ~experimentalForcePlate1);
end

momentIndices = contains(experimentalLabels, "_m");
forceIndices = contains(experimentalLabels, "_v");
includedIndices = momentIndices | forceIndices;

experimentalLabels = experimentalLabels(includedIndices);
modelGR = modelGR(:, includedIndices);
experimentalGR = experimentalGR(:, includedIndices);

% Spline experimental time to the same time points as the model. 
experimentalSpline = makeGcvSplineSet(experimentalTime, ... 
    experimentalGR, experimentalLabels);
resampledExperimental = evaluateGcvSplines(experimentalSpline, ...
    experimentalLabels, modelTime);

if nargin < 3
    figureWidth = 3;
end
if nargin < 4
    figureHeight = 2;
end
figureSize = figureWidth * figureHeight;

figure(Name = "Treatment Optimization Ground Reactions")
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "Time [s]")
ylabel(t, "Ground Reactions")
for i=1:numel(experimentalLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Ground Reactions")
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Time [s]")
        ylabel(t, "Ground Reactions")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    plot(experimentalTime, experimentalGR(:, i), LineWidth=2);
    plot(modelTime, modelGR(:, i), LineWidth=2);
    hold off
    rmse = rms(resampledExperimental(:, i) - modelGR(:, i));
    title(sprintf("%s \n RMSE: %.4f", ...
    strrep(experimentalLabels(i), "_", " "), rmse))
    if subplotNumber==1
        legend("Experimental", "Model")
    end
    xlim([0, experimentalTime(end)])
    subplotNumber = subplotNumber + 1;
end
end
