% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the necessary inputs and produces the results of IK,
% ID, and MuscleAnalysis so the values can be used as inputs for
% MuscleTendonPersonalization.
%
% (struct, struct) -> (None)
% Prepares raw data for MuscleTendonPersonalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function NeuralControlPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);

precalInputs = parseMuscleTendonLengthInitializationSettingsTree(settingsTree);
if isstruct(precalInputs)
    optimizedInitialGuess = MuscleTendonLengthInitialization(precalInputs);
    inputs = updateNcpInitialGuess(inputs, precalInputs, ...
        optimizedInitialGuess);
end

optimizedValues = NeuralControlPersonalization(inputs, params);
save("results.mat", "optimizedValues", "-mat")
%% results is a structure, report not implemented yet
results = calcFinalMuscleActivations(optimizedValues, inputs);
results = calcFinalModelMoments(results, inputs);
save("results.mat", "results", '-mat')
reportNeuralControlPersonalizationResults(optimizedValues, inputs, params)
saveNeuralControlPersonalizationResults(inputs.model, ...
    inputs.coordinates, results, resultsDirectory);
end