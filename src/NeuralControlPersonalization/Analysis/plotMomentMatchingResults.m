% This function is part of the NMSM Pipeline, see file for full license.
%
% Plot modeled and experimental moments for one trial resulting from Neural 
% Control Personalization or other tools from files. These plots include 
% RMS error. 
%
% (string, string, double, double) -> (None)
% Plot modeled and experimental moments from files. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Benjamin J. Fregly, Spencer Williams                         %
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

function plotMomentMatchingResults(experimentalMomentsFile, ...
    modeledMomentsFile, figureWidth, figureHeight, figureNumber)
import org.opensim.modeling.Storage
[experimentalColumns, experimentalTime, experimentalMoments] = ...
    parseMotToComponents(org.opensim.modeling.Model(), ...
    Storage(experimentalMomentsFile));
[modeledColumns, modeledTime, modeledMoments] = parseMotToComponents( ...
    org.opensim.modeling.Model(), Storage(modeledMomentsFile));

if experimentalTime(1) ~= 0
    experimentalTime = experimentalTime - experimentalTime(1);
end
experimentalTime = experimentalTime / experimentalTime(end);
if modeledTime(1) ~= 0
    modeledTime = modeledTime - modeledTime(1);
end
modeledTime = modeledTime / modeledTime(end);

includedColumns = logical(ismember(experimentalColumns, modeledColumns) ...
    + ismember(experimentalColumns + "_moment", modeledColumns));
experimentalMoments = experimentalMoments(includedColumns, :);
experimentalColumns = experimentalColumns(includedColumns);

% Sort by left/right
rightIndices = contains(experimentalColumns, "_r_");
leftIndices = ~rightIndices;
experimentalColumns = [experimentalColumns(rightIndices), ...
    experimentalColumns(leftIndices)];
modeledColumns = [modeledColumns(rightIndices), ...
    modeledColumns(leftIndices)];
experimentalMoments = [experimentalMoments(rightIndices, :); ...
    experimentalMoments(leftIndices, :)];
modeledMoments = [modeledMoments(rightIndices, :); ...
    modeledMoments(leftIndices, :)];

if nargin < 3
    figureWidth = ceil(sqrt(numel(experimentalColumns)));
    figureHeight = ceil(numel(experimentalColumns)/figureWidth);
elseif nargin < 4
    figureHeight = ceil(sqrt(numel(experimentalColumns)));
end
if nargin < 5
    figureNumber = 1;
end
figureSize = figureWidth * figureHeight;
splitFileName = split(modeledMomentsFile, ["/", "\"]);
for k = 1 : numel(splitFileName)
    if ~strcmp(splitFileName(k), "..")
        figureName = splitFileName(k);
        break
    end
end
figure(Name = figureName, ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
colors = getPlottingColors();
subplotNumber = 1;
figureNumber = 1;
figureIndex = 1;
hasLegend = false;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "% Gait Cycle [0-100%]")
% xlabel(t, "Time Points [s]")
ylabel(t, "Joint Moments [Nm]")

for i = 1:length(experimentalColumns)
    if i > figureSize * figureIndex
        figureIndex = figureIndex + 1;
        figure(Name = figureName, ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='compact', Padding='compact');
        subplotNumber = 1;
        hasLegend = false;
    end
    nexttile(subplotNumber)
    plot(modeledTime*100, experimentalMoments(i, :), color=colors(1), LineWidth=2)
    modeledIndex = find(experimentalColumns(i) == modeledColumns);
    if isempty(modeledIndex)
        modeledIndex = find(experimentalColumns(i) + "_moment" == modeledColumns);
    end
    if ~isempty(modeledIndex)
        hold on
        plot(modeledTime*100, modeledMoments(modeledIndex, :), color=colors(2), LineWidth=2);
        if ~hasLegend
            legend("Experimental Moments", "Modeled Moments")
            hasLegend = true;
        end
        hold off
        error = rms(experimentalMoments(i, :) - ...
            modeledMoments(modeledIndex, :));
    else
        error = "N/A";
    end
    title(strrep(experimentalColumns(i), "_", " ") + newline + ...
        " RMSE: " + error)
    xlim("tight")
    subplotNumber = subplotNumber + 1;
end
end
