% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing passive moment data 
% and creates plots of experimental and modeled passive moment curves.
%
% (string) -> (None)
% Plot passive moment curves from file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Di Ao, Marleny Vega, Robert Salati                           %
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

function plotMtpPassiveMomentCurves(resultsDirectory)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
[momentNames, passiveMomentsExperimental] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "passiveJointMomentsExperimental"));
[~, passiveMomentsModel] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "passiveJointMomentsModeled"));
momentNames = strrep(momentNames, '_', ' ');
meanMomentsExperimental = mean(passiveMomentsExperimental, 3);
stdMomentsExperimental = std(passiveMomentsExperimental, [], 3);
meanMomentsModel = mean(passiveMomentsModel, 3);
stdMomentsModel = std(passiveMomentsModel, [], 3);
maxMoment = max([max(meanMomentsExperimental, [], 'all'), ...
    max(meanMomentsModel, [], 'all')]);
minMoment = min([min(meanMomentsExperimental, [], 'all'), ...
    min(meanMomentsModel, [], 'all')]);
time = 1:1:size(meanMomentsModel,1);

figureWidth = ceil(sqrt(numel(momentNames)));
figureHeight = ceil(numel(momentNames)/figureWidth);

figure(Name = strcat(resultsDirectory, " Passive Moment Curves"), ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');

for i = 1:numel(momentNames)
    nexttile(i);
    hold on
    plotMeanAndStd(meanMomentsExperimental(:,i), stdMomentsExperimental(:,i), ...
        time, 'k-')
    plotMeanAndStd(meanMomentsModel(:,i), stdMomentsModel(:,i), time, 'r-')
    hold off
    set(gca, fontsize=11)
    rmse = rms(passiveMomentsExperimental(:,i) - passiveMomentsModel(:,i));
    title(sprintf("%s \n RMSE: %.4f", ...
        momentNames(i), rmse), FontSize=12)
    axis([time(1) time(end) minMoment maxMoment])
    if i == 1
        legend("Experimental", "Model")
    end
    if mod(i,figureWidth) == 1
        ylabel("Moment [Nm]")
    end
end
end

