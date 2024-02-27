% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads two .sto files: 1) experimental loads, and 2) model
% loads, and plots them. There are 2 optional arguments for figure width
% and figure height. If no optional arguments are given, the figure size is
% automatically adjusted to fit all data on one plot. Giving just figure
% width imposes the width and fits the height to fit on one plot. Giving
% both arguments will impose both figure height and width, and create
% multiple plots as needed.
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
function plotTreatmentOptimizationJointLoads(experimentalMomentsFile, ...
    modelMomentsFile, figureWidth, figureHeight)

import org.opensim.modeling.Storage
experimentalLoadsStorage = Storage(experimentalMomentsFile);
labels = getStorageColumnNames(experimentalLoadsStorage);
experimentalLoads = storageToDoubleMatrix(experimentalLoadsStorage)';
experimentalTime = findTimeColumn(experimentalLoadsStorage);
if experimentalTime(1) ~= 0
    experimentalTime = experimentalTime - experimentalTime(1);
end
modelLoadsStorage = Storage(modelMomentsFile);
modelLoads = storageToDoubleMatrix(modelLoadsStorage)';
modelTime = findTimeColumn(modelLoadsStorage);
if modelTime(1) ~= 0
    modelTime = modelTime - modelTime(1);
end

% Spline experimental time to the same time points as the model. 
experimentalSpline = makeGcvSplineSet(experimentalTime, ... 
    experimentalLoads, labels);
resampledExperimental = evaluateGcvSplines(experimentalSpline, ...
    labels, modelTime);

if nargin < 3
    figureWidth = ceil(sqrt(numel(labels)));
    figureHeight = ceil(numel(labels)/figureWidth);
elseif nargin < 4
    figureHeight = ceil(numel(labels)/figureWidth);
end
figureSize = figureWidth * figureHeight;

figure(Name="Treatment Optimization Joint Loads", ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "Time [s]")
ylabel(t, "Joint Load")
for i=1:numel(labels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Joint Loads", ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Time [s]")
        ylabel(t, "Joint Load")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    plot(experimentalTime, experimentalLoads(:, i), LineWidth=2);
    plot(modelTime, modelLoads(:, i), LineWidth=2);
    hold off
    rmse = rms(resampledExperimental(:, i) - modelLoads(:, i));
    mae = mean(abs(resampledExperimental(:, i) - modelLoads(:, i)));
    
    if contains(labels(i), "moment")
        title(sprintf("%s \n RMSE: %.4f", ...
            strcat(strrep(labels(i), "_", " "), " [Nm]"), rmse))
    elseif contains(labels(i), "force")
        title(sprintf("%s \n RMSE: %.4f", ...
            strcat(strrep(labels(i), "_", " "), " [N]"), rmse))
    else
        title(sprintf("%s \n RMSE: %.4f", ...
            strrep(labels(i), "_", " "), rmse))
    end
    
    if subplotNumber==1
        legend("Experimental", "Model")
    end

    xlim([0, experimentalTime(end)])
    maxLoad = max([experimentalLoads(:, i); modelLoads(:, i)],[], "all");
    minLoad = min([experimentalLoads(:, i); modelLoads(:, i)],[], "all");
    if maxLoad-minLoad < 10
        ylim([(maxLoad+minLoad)/2-10, (maxLoad+minLoad)/2+10])
    else
        ylim([ ...
            min([modelLoads(1:end-1, i); experimentalLoads(:, i)])-5, ...
            max([modelLoads(1:end-1, i); experimentalLoads(:, i)])+5])
    end
   
    % if subplotNumber > figureSize-figureHeight
    %     xlabel("Time [s]")
    % end
    subplotNumber = subplotNumber + 1;
end
end

