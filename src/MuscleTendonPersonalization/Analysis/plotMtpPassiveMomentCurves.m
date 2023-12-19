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
meanPassiveMomentsExperimental = mean(passiveMomentsExperimental, 3);
stdPassiveMomentsExperimental = std(passiveMomentsExperimental, [], 3);
meanPassiveMomentsModel = mean(passiveMomentsModel, 3);
stdPassiveMomentsModel = std(passiveMomentsModel, [], 3);
maxMoment = max([max(meanPassiveMomentsExperimental, [], 'all'), ...
    max(meanPassiveMomentsModel, [], 'all')]);
minMoment = min([min(meanPassiveMomentsExperimental, [], 'all'), ...
    min(meanPassiveMomentsModel, [], 'all')]);

numWindows = ceil(sqrt(numel(momentNames)));
t = 1:1:size(meanPassiveMomentsModel,1);
figure(Name = "Passive Moment Curves", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])

for i = 1:numel(momentNames)
    subplot(numWindows, numWindows, i)
    hold on

    plot(meanPassiveMomentsExperimental(:,i), 'k-', linewidth=2)
    plot(meanPassiveMomentsModel(:,i), 'r-', linewidth=2)

    fillRegionExperimental = [(meanPassiveMomentsExperimental(:,i)+stdPassiveMomentsExperimental(:,i));
        flipud((meanPassiveMomentsExperimental(:,i)-stdPassiveMomentsExperimental(:,i)))];
    fill([t, fliplr(t)]', fillRegionExperimental, 'k', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    fillRegionModel = [(meanPassiveMomentsModel(:,i)+stdPassiveMomentsModel(:,i));
        flipud((meanPassiveMomentsModel(:,i)-stdPassiveMomentsModel(:,i)))];
    fill([t, fliplr(t)]', fillRegionModel, 'r', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    hold off
    set(gca, fontsize=11)
    title(momentNames(i), FontSize=12)
    axis([1 size(meanPassiveMomentsModel, 1) minMoment maxMoment])
    if i == 1
        legend("Experimental", "Model")
    end
    if mod(i,4) == 1
        ylabel("Moment [Nm]")
    end
    if i>numel(momentNames)-numWindows
        xlabel("Time Points")
    end
end
end

