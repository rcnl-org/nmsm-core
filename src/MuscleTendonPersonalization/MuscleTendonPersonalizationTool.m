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
[mtpInputs, mtpParams, resultsDirectory] = ...
    parseMuscleTendonPersonalizationSettingsTree(settingsTree);
if mtpParams.performPrecalibration
    precalInputs = parsePreCalibrationSettingsTree(settingsTree);
    optimizedInitialGuess = PreCalibration(precalInputs);
    mtpInputs = updateMtpInputs(mtpInputs, precalInputs, ...
        optimizedInitialGuess);
end
optimizedParams = MuscleTendonPersonalization(mtpInputs, mtpParams);
%% results is a structure, report not implemented yet
finalValues = makeMtpValuesAsStruct([], optimizedParams, zeros(1, 7));
results = calcMtpSynXModeledValues(finalValues, mtpInputs, mtpParams);
results.time = mtpInputs.emgTime(:, mtpInputs.numPaddingFrames + 1 : ...
    end - mtpInputs.numPaddingFrames);
% results = calcFinalMuscleActivations(optimizedParams, inputs);
% results = calcFinalModelMoments(results, inputs);
save("results.mat", "results", "finalValues", '-mat')
% reportMuscleTendonPersonalization(inputs.model, results)
saveMuscleTendonPersonalizationResults(mtpInputs.model, ...
    mtpInputs.coordinates, finalValues, results, resultsDirectory);
end