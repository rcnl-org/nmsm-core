% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing passive force curves 
% and creates plots of them.
%   
% (string) -> (None)
% Plot passive force curves from file.

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
function plotPassiveForceCurves(resultsDirectory)
[muscleNames, passiveForce] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "passiveForcesExperimental"));
muscleNames = strrep(muscleNames, '_', ' ');
meanPassiveForce = mean(passiveForce, 3);
stdPassiveForce = std(passiveForce, [], 3);
maxForce = max(meanPassiveForce, [], 'all');
numWindows = ceil(sqrt(numel(muscleNames)));

figure(Name = "Passive Force Curves", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])
t = 1:1:size(meanPassiveForce,1);
for i = 1:numel(muscleNames)
    subplot(numWindows, numWindows, i)
    hold on
    plot(meanPassiveForce(:,i), 'b-', linewidth=2)

    fillRegion = [(meanPassiveForce(:,i)+stdPassiveForce(:,i));
        flipud((meanPassiveForce(:,i)-stdPassiveForce(:,i)))];
    fill([t, fliplr(t)]', fillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    hold off
    set(gca, fontsize=11)
    axis([1 size(meanPassiveForce, 1) 0 maxForce])
    title(muscleNames(i), FontSize=12);
    if mod(i,3) == 1
        ylabel("Magnitude")
    end
    if i>numel(muscleNames)-numWindows
        xlabel("Time Points")
    end
end

