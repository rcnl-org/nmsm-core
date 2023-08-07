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
if nargin < 3
    figureWidth = 4;
end
if nargin < 4
    figureHeight = 2;
end
if nargin < 5
    figureNumber = 1;
end
figureSize = figureWidth * figureHeight;

[experimentalColumns, experimentalTime, experimentalMoments] = ...
    parseMotToComponents(org.opensim.modeling.Model(), ...
    Storage(experimentalMomentsFile));
[modeledColumns, modeledTime, modeledMoments] = parseMotToComponents( ...
    org.opensim.modeling.Model(), Storage(modeledMomentsFile));

includedColumns = ismember(experimentalColumns, modeledColumns);
experimentalMoments = experimentalMoments(includedColumns, :);
experimentalColumns = experimentalColumns(includedColumns);

subplotNumber = 1;
hasLegend = false;
figure(figureNumber)
figureIndex = 1;
for i = 1:length(experimentalColumns)
    if i > figureSize * figureIndex
        figureIndex = figureIndex + 1;
        figure(figureNumber + figureIndex - 1)
        subplotNumber = 1;
        hasLegend = false;
    end
    subplot(figureHeight, figureWidth, subplotNumber)
    plot(experimentalTime, experimentalMoments(i, :), 'LineWidth', 2)
    modeledIndex = find(experimentalColumns(i) == modeledColumns);
    if ~isempty(modeledIndex)
        hold on
        plot(modeledTime, modeledMoments(modeledIndex, :), 'LineWidth', 2);
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
    xlim([modeledTime(1) modeledTime(end)])
    subplotNumber = subplotNumber + 1;
end
end
