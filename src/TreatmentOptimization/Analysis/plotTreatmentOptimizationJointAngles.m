% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing inverse dynamics
% joint moments and model joint moments and creates plots of them.
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
function plotTreatmentOptimizationJointAngles(experimentalAnglesFile, ...
    modelAnglesFile, figureWidth, figureHeight)

import org.opensim.modeling.Storage
experimentalAnglesStorage = Storage(experimentalAnglesFile);
labels = getStorageColumnNames(experimentalAnglesStorage);
experimentalAngles = storageToDoubleMatrix(experimentalAnglesStorage)';
experimentalAngles = experimentalAngles .* 180/pi;
experimentalTime = findTimeColumn(experimentalAnglesStorage);
if experimentalTime(1) ~= 0
    experimentalTime = experimentalTime - experimentalTime(1);
end
modelAnglesStorage = Storage(modelAnglesFile);
modelAngles = storageToDoubleMatrix(modelAnglesStorage)';
modelAngles = modelAngles .* 180/pi;
modelTime = findTimeColumn(modelAnglesStorage);
if modelTime(1) ~= 0
    modelTime = modelTime - modelTime(1);
end

% Spline experimental time to the same time points as the model. 
experimentalSpline = makeGcvSplineSet(experimentalTime, ... 
    experimentalAngles, labels);
resampledExperimental = evaluateGcvSplines(experimentalSpline, ...
    labels, modelTime);

if nargin < 3
    figureWidth = ceil(sqrt(numel(labels)));
    figureHeight = ceil(numel(labels)/figureWidth);
elseif nargin < 4
    figureHeight = ceil(numel(labels)/figureWidth);
end
figureSize = figureWidth * figureHeight;

figure(Name = "Treatment Optimization Joint Angles", ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Time [s]")
ylabel(t, "Joint Angle [deg]")
for i=1:numel(labels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Joint Angles", ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Time [s]")
        ylabel(t, "Joint Angle [deg]")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    plot(experimentalTime, experimentalAngles(:, i), LineWidth=2);
    plot(modelTime, modelAngles(:, i), LineWidth=2);
    hold off
    rmse = rms(resampledExperimental(:, i) - modelAngles(:, i));
    title(sprintf("%s \n RMSE: %.4f", ...
        strrep(labels(i), "_", " "), rmse));

    if subplotNumber==1
        legend("Experimental", "Model")
    end

    xlim([0, experimentalTime(end)])
    maxAngle = max([experimentalAngles(:, i); modelAngles(:, i)],[], "all");
    minAngle = min([experimentalAngles(:, i); modelAngles(:, i)],[], "all");
    if maxAngle-minAngle < 10
        ylim([(maxAngle+minAngle)/2-10, (maxAngle+minAngle)/2+10])
    end

    % if subplotNumber > figureSize-figureHeight
    %     xlabel("Time [s]")
    % end
    subplotNumber = subplotNumber + 1;
end