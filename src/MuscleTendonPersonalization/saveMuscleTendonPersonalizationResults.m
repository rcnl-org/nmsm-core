% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the result struct and writes the values to the
% appropriate .osimx muscle model, .mot muscle moment, and .sto muscle
% activation files. The model is included in instances where the results
% are relative to the original model, which is used for reference.
%
% (Model, struct, string, string, string) -> (None) 
% Saves results in the struct to the given filenames

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function saveMuscleTendonPersonalizationResults(modelFileName, ...
    coordinateNames, results, resultsDirectory)

model = Model(modelFileName);
muscleColumnNames = getEnabledMusclesInOrder(model);
[~, name, ~] = fileparts(modelFileName);
for i = 1:size(results.muscleActivations, 1)
% Need to figure out how to print out individuals file names for each trial
writeToSto(muscleColumnNames, results.time(i, :), ...
    squeeze(results.muscleActivations(i, :, :))', fullfile(resultsDirectory, ...
    strcat(name, "_muscleActivations_", num2str(i), ".sto")));
writeToSto(coordinateNames, results.time(i, :), ...
    squeeze(results.modelMoments(i, :, :))', fullfile(resultsDirectory, ...
    strcat(name, "_modelMoments_", num2str(i), ".sto")));
end
writeMuscleTendonPersonalizationOsimxFile(modelFileName,...
    results.optimizedParams, fullfile(resultsDirectory, ...
    strcat(name, "_muscleModel.xml")));
end

