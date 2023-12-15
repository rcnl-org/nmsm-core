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
function plotJointMoments(resultsDirectory)
[jointLabels, idMoments] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "inverseDynamicsJointMoments"));
[~, noResidualMoments] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "modelJointMomentsNoSynx"));
[~, withResidualMoments] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "modelJointMomentsSynx"));
jointLabels = strrep(jointLabels, '_', ' ');
meanIdMoments = mean(idMoments, 3);
stdIdMoments = std(idMoments, [], 3);
meanNoResidualMoments = mean(noResidualMoments, 3);
stdNoResidualMoments = std(noResidualMoments, [], 3);
meanWithResidualMoments = mean(withResidualMoments, 3);
stdWithResidualMoments = std(withResidualMoments, [], 3);
maxMoment = max([ ...
    max(meanIdMoments, [], "all"), ...
    max(meanNoResidualMoments, [], "all") ...
    max(meanWithResidualMoments, [], "all")]);
minMoment = min([ ...
    min(meanIdMoments, [], "all"), ...
    min(meanNoResidualMoments, [], "all") ...
    min(meanWithResidualMoments, [], "all")]);

figure(Name = "Joint Moments", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])
t = 1:1:size(meanIdMoments,1);
numWindows = numel(jointLabels);
for i=1:numel(jointLabels)
    subplot(2, numWindows, i);
    hold on
    plot(meanNoResidualMoments(:,i), 'r-', linewidth=2)
    plot(meanIdMoments(:,i), 'b-', linewidth=2)

    noResidualFillRegion = [(meanNoResidualMoments(:,i)+stdNoResidualMoments(:,i));
        flipud(meanNoResidualMoments(:,i)-stdNoResidualMoments(:,i))];
    idFillRegion = [(meanIdMoments(:,i)+stdIdMoments(:,i));
        flipud(meanIdMoments(:,i)-stdIdMoments(:,i))];
    fill([t, fliplr(t)]', noResidualFillRegion, 'r', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    fill([t, fliplr(t)]', idFillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    hold off
    title(jointLabels(i), fontsize=12)
    axis([0 size(meanIdMoments, 1) minMoment, maxMoment])
    if i == 1
        legend("Mean Moment No Residual", "Mean Inverse Dynamics Moment")
        ylabel("Joint Moment [Nm]")
    end
    subplot(2, numWindows, i+3)
    hold on
    plot(meanWithResidualMoments(:,i), 'r-', linewidth=2)
    plot(meanIdMoments(:,i), 'b-', linewidth=2)

    withResidualFillRegion = [(meanWithResidualMoments(:,i)+stdWithResidualMoments(:,i));
        flipud(meanWithResidualMoments(:,i)-stdWithResidualMoments(:,i))];
    idFillRegion = [(meanIdMoments(:,i)+stdIdMoments(:,i));
        flipud(meanIdMoments(:,i)-stdIdMoments(:,i))];
    fill([t, fliplr(t)]', withResidualFillRegion, 'r', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    fill([t, fliplr(t)]', idFillRegion, 'r', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    hold off
    set(gca, fontsize=11)
    title(jointLabels(i), FontSize=12)
    xlabel("Time Point")
    axis([0 size(meanIdMoments, 1) minMoment, maxMoment])
    if i == 1
        legend("Mean Moment With Residual", "Mean Inverse Dynamics Moment")
        ylabel("Joint Moment [Nm]")
    end

end
end

