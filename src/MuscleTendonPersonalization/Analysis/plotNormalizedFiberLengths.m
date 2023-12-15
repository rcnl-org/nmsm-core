% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing normalized fiber
% lengths and creates plots of them.
%
% (string) -> (None)
% Plot normalized fiber lengths from file.

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
function plotNormalizedFiberLengths(resultsDirectory)
[muscleNames, normalizedFiberLengths] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "normalizedFiberLengths"));
muscleNames = strrep(muscleNames, '_', ' ');
meanFiberLengths = mean(normalizedFiberLengths, 3);
stdFiberLengths = std(normalizedFiberLengths, [], 3);

figure(Name = "Normalized Fiber Lengths", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])
t = 1:1:size(meanFiberLengths,1);
numWindows = ceil(sqrt(numel(muscleNames)));
passiveLower = ones(size(t))*0.7;
passiveUpper = ones(size(t));

for i=1:numel(muscleNames)
    subplot(numWindows, numWindows, i);
    hold on
    plot(meanFiberLengths(:,i), 'b-', LineWidth=2);

    fillRegion = [(meanFiberLengths(:,i)+stdFiberLengths(:,i));
        flipud(meanFiberLengths(:,i)-stdFiberLengths(:,i))];
    fill([t, fliplr(t)]', fillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

    plot(t, passiveUpper, 'r--', LineWidth=2);
    plot(t, passiveLower, 'r--', LineWidth=2);
    hold off
    set(gca, fontsize=11)
    axis([1 size(meanFiberLengths, 1) 0 1.5])
    title(muscleNames(i), FontSize=12);
    if mod(i,3) == 1
        ylabel('Normalized Fiber Length', FontSize=12)
    end
    if i>numel(muscleNames)-numWindows
        xlabel("Time Points", FontSize=12)
    end
end

end

