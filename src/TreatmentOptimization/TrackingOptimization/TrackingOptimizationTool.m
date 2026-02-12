% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a properly formatted XML file and runs the
% TrackingOptimization module and saves the results correctly for
% use in the OpenSim GUI.
%
% (string) -> (None)
% Run TrackingOptimization from settings file

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

function TrackingOptimizationTool(settingsFileName)
tic
try 
    verifyProjectOpened()
catch
    error("NMSM Pipeline Project is not opened.")
end
settingsTree = xml2struct(settingsFileName);
verifyVersion(settingsTree, "TrackingOptimizationTool");
[inputs, params] = parseTrackingOptimizationSettingsTree(settingsTree);
verifyTreatmentOptimizationCostAndConstraintTerms(inputs);
outputLogFile = fullfile("commandWindowOutput.txt");
diary(outputLogFile)
inputs = normalizeSynergyData(inputs);
inputs = setupMuscleSynergies(inputs);
inputs = makeTreatmentOptimizationInputs(inputs, params);
[inputs, outputs] = solveOptimalControlProblem(inputs, params);
saveTrackingOptimizationResults(outputs, inputs);
fprintf("Tracking Optimization Runtime: %f Hours\n", toc/3600);
diary off
try
    copyfile(settingsFileName, fullfile(inputs.resultsDirectory, settingsFileName));
    movefile(outputLogFile, fullfile(inputs.resultsDirectory, outputLogFile));
catch
end
end
