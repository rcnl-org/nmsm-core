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
function plotMtpJointMoments(resultsDirectory)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
numRows = 1;

[jointLabels, idMoments] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "inverseDynamicsJointMoments"));

[~, modelMoments] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "modelJointMoments"));

if exist(fullfile(analysisDirectory, "modelJointMomentsSynx"), "dir")
    [~, modelMomentsSynx] = extractMtpDataFromSto( ...
        fullfile(analysisDirectory, "modelJointMomentsSynx"));
    numRows = numRows + 1;
else
    modelMomentsSynx = [];
end

if exist(fullfile(analysisDirectory, "modelJointMomentsSynxNoResiduals"), "dir")
    [~, modelMomentsSynxNoResiduals] = extractMtpDataFromSto( ...
        fullfile(analysisDirectory, "modelJointMomentsSynxNoResiduals"));
    numRows = numRows + 1;
else
    modelMomentsSynxNoResiduals = [];
end

jointLabels = strrep(jointLabels, '_', ' ');
meanIdMoments = mean(idMoments, 3);
stdIdMoments = std(idMoments, [], 3);
meanMoments = mean(modelMoments, 3);
stdMoments = std(modelMoments, [], 3);
meanMomentsSynx = mean(modelMomentsSynx, 3);
stdMomentsSynx = std(modelMomentsSynx, [], 3);
meanMomentsSynxNoResidual = mean(modelMomentsSynxNoResiduals, 3);
stdMomentsSynxNoResidual = std(modelMomentsSynxNoResiduals, [], 3);
maxMoment = max([ ...
    max(meanIdMoments, [], "all"), ...
    max(meanMoments, [], "all"), ...
    max(meanMomentsSynx, [], "all"), ...
    max(meanMomentsSynxNoResidual, [], "all")]);
minMoment = min([ ...
    min(meanIdMoments, [], "all"), ...
    min(meanMoments, [], "all"), ...
    min(meanMomentsSynx, [], "all"), ...
    min(meanMomentsSynxNoResidual, [], "all")]);

figure(Name = "Joint Moments", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])
time = 1:1:size(meanIdMoments,1);
numColumns = numel(jointLabels);
for i=1:numel(jointLabels)
    if ~isempty(meanMoments)
        subplot(numRows, numColumns, i);
        hold on
        plotMeanAndStd(meanMoments(:,i), stdMoments(:,i), time, 'r-')
        plotMeanAndStd(meanIdMoments(:,i), stdIdMoments(:,i), time, 'b-')
        hold off
        set(gca, fontsize=11)
        title(jointLabels(i), fontsize=12)
        axis([0 size(meanIdMoments, 1) minMoment, maxMoment])
        if i == 1
            legend("Mean Moment No Synx", "Mean Inverse Dynamics Moment")
            ylabel("Joint Moment [Nm]")
        end
    end
    if ~isempty(meanMomentsSynx)
        subplot(numRows, numColumns, i+numColumns)
        hold on
        plotMeanAndStd(meanMomentsSynx(:,i), stdMomentsSynx(:,i), time, 'r-')
        plotMeanAndStd(meanIdMoments(:,i), stdIdMoments(:,i), time, 'b-')
        hold off
        set(gca, fontsize=11)
        title(jointLabels(i), FontSize=12)
        axis([0 size(meanIdMoments, 1) minMoment, maxMoment])
        if i == 1
            legend("Mean Moment Synx", "Mean Inverse Dynamics Moment")
            ylabel("Joint Moment [Nm]")
        end
    end
    if ~isempty(meanMomentsSynxNoResidual)
        subplot(numRows, numColumns, i+2*numColumns)
        hold on
        plotMeanAndStd(meanMomentsSynxNoResidual(:,i), stdMomentsSynxNoResidual(:,i), time, 'r-')
        plotMeanAndStd(meanIdMoments(:,i), stdIdMoments(:,i), time, 'b-')
        hold off
        set(gca, fontsize=11)
        title(jointLabels(i), FontSize=12)
        axis([0 size(meanIdMoments, 1) minMoment, maxMoment])
        if i == 1
            legend("Mean Moment Synx No Residual", "Mean Inverse Dynamics Moment")
            ylabel("Joint Moment [Nm]")
        end
    end
    xlabel("Time Point")
end
end