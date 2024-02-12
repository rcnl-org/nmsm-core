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
function plotTreatmentOptimizationActivations(experimentalActivationsFile, ...
    modelActivationsFile, figureWidth, figureHeight)
if nargin < 3
    figureWidth = 8;
end
if nargin < 4
    figureHeight = 8;
end
figureSize = figureWidth * figureHeight;
import org.opensim.modeling.Storage
experimentalActivationsStorage = Storage(experimentalActivationsFile);
muscleLabels = getStorageColumnNames(experimentalActivationsStorage);
experimentalActivations = storageToDoubleMatrix(experimentalActivationsStorage)';
experimentalTime = findTimeColumn(experimentalActivationsStorage);
if experimentalTime(1) ~= 0
    experimentalTime = experimentalTime - experimentalTime(1);
end
modelActivationsStorage = Storage(modelActivationsFile);
modelActivations = storageToDoubleMatrix(modelActivationsStorage)';
modelTime = findTimeColumn(modelActivationsStorage);
if modelTime(1) ~= 0
    modelTime = modelTime - modelTime(1);
end
figure(Name="Treatment Optimization Activations", ...
    Units='normalized', ...
    Position=[0 0 1 1])
subplotNumber = 1;
figureNumber = 1;
for i=1:numel(muscleLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Activations", ...
            Units='normalized', ...
            Position=[0 0 1 1])
        subplotNumber = 1;
    end
    subplot(figureWidth, figureHeight, subplotNumber)
    hold on
    plot(experimentalTime, experimentalActivations(:, i))
    plot(modelTime, modelActivations(:, i))
    hold off
    title(strrep(muscleLabels(i), "_", " "));
    if subplotNumber == 1
        legend("Experimental Activations", "Model Activations")
    end
    subplotNumber = subplotNumber + 1;
end
end

