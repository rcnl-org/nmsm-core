% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by 
% saveMuscleTendonPersonalizationResults.m containing model and 
% experimental joint moments and outputs RMSE error via print command. 
%
% (string) -> (None)
% Print joint moment matching error from file.

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

function printMtpJointMomentMatchingError(resultsDirectory)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
[jointMomentLabels, muscleJointMoments] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "modelMoments"));
[~, inverseDynamicsMoments] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "inverseDynamicsJointMoments"));
jointMomentsRmse = zeros(size(jointMomentLabels));
jointMomentsMae = zeros(size(jointMomentLabels));
for i = 1 : size(muscleJointMoments, 2)
    jointMomentsRmse(i) = sqrt(sum((muscleJointMoments(:, i) - ...
        inverseDynamicsMoments(:, i)) .^ 2, 'all') / ...
        (numel(inverseDynamicsMoments(:, 1)) - 1));
    jointMomentsMae(i) = sum(abs(muscleJointMoments(:, i) - ...
        inverseDynamicsMoments(:, i)) / ...
        numel(inverseDynamicsMoments(:, 1)), 'all');
end
fprintf(['The root mean sqrt (RMS) errors between model-predicted ' ...
    'and inverse dynamic moments are: \n' ]);
fprintf(['\n ' num2str(jointMomentsRmse) ' \n']);
fprintf(['The mean absolute errors (MAEs) between model-predicted ' ...
    'and inverse dynamic moments are: \n' ]);
fprintf(['\n ' num2str(jointMomentsMae) ' \n']);
end

