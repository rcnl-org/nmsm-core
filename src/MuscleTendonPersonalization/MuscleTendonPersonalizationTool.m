% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a properly formatted XML file and runs the
% MuscleTendonPersonalization module and saves the results correctly for
% use in the OpenSim GUI.
%
% (string) -> (None)
% Run MuscleTendonPersonalization from settings file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function MuscleTendonPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
verifyVersion(settingsTree, "MuscleTendonPersonalizationTool");
[inputs, params, resultsDirectory] = ...
    parseMuscleTendonPersonalizationSettingsTree(settingsTree);
precalInputs = parseMuscleTendonLengthInitializationSettingsTree(settingsTree);

if isstruct(precalInputs)
    optimizedInitialGuess = MuscleTendonLengthInitialization(precalInputs);
    inputs = updateMtpInitialGuess(inputs, precalInputs, ...
        optimizedInitialGuess);
else
    precalInputs = struct('optimizeIsometricMaxForce', false);
end

optimizedParams = MuscleTendonPersonalization(inputs, params);
if params.performMuscleTendonLengthInitialization
    saveMuscleTendonOptimizationParams(".\mtpResults\Analysis", ...
        optimizedParams, inputs, precalInputs)
else
    saveMuscleTendonOptimizationParams(".\mtpResults\Analysis", ...
        optimizedParams, inputs)
end

finalValues = makeMtpValuesAsStruct([], optimizedParams, zeros(1, 7));
if precalInputs.optimizeIsometricMaxForce
    finalValues.maxIsometricForce = inputs.maxIsometricForce;
end
results = calcMtpSynXModeledValues(finalValues, inputs, params);

results.time = inputs.emgTime(:, inputs.numPaddingFrames + 1 : ...
    end - inputs.numPaddingFrames);
saveMuscleTendonPersonalizationResults(inputs.model, ...
    inputs.osimxFileName, inputs.prefixes, inputs.coordinateNames, ...
    finalValues, results, resultsDirectory, inputs.muscleTendonColumnNames);
% saveMuscleTendonOptimizationResults(optimizedParams, inputs, precalInputs, ...
%     ".\mtpResults\Analysis")
% save("params.mat", "params")
% save("optimizedParams.mat", "optimizedParams")
% save("precalInputs.mat", "precalInputs")
% save("inputs.mat", "inputs")
end
