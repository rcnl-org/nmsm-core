% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing optimized Hill-type
% muscle-tendon model parameters and creates a bar plot of them.
%
% (string) -> (None)
% Plot Hill-Type Muscle-Tendon model parameters from file.

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
function plotMtpHillTypeMuscleParams(resultsDirectory)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
[muscleNames, params] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "muscleModelParameters"));
muscleNames = strrep(muscleNames, '_', ' ');
figure(Name = "Muscle Model Parameters", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])

paramLabels = ["Activation Time Constant", ...
    "Activation Nonlinearity", ...
    "Electromechanical Time Delay", ...
    "EMG Scaling Factor", ...
    "Optimal Fiber Length Scaling Factor", ...
    "Tendon Slack Length Scaling Factor"];
for i = 1 : numel(paramLabels)
    subplot(1, 6, i)
    barh(params(i,:))

    title(textwrap(paramLabels(i), 20), FontSize=12)
    if i == 1
        set(gca, yticklabels = muscleNames, fontsize=11);
    else
        set(gca, yticklabels = [], fontsize=11);
    end
end
end