% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves optimized Hill-type muscle-tendon model parameters
% output by MTP to a .sto file in a directory specified by
% resultsDirectory. Each row in the .sto file corresponds to a parameter.
% In order from top to bottom, these are: activation time constants, 
% activation nonlinearity constants, electromechanical delays, emg scale
% factors, optimal fiber length scale factors, tendon slack length scale
% factors. 
%
% (struct, struct, struct, struct, struct, string) -> (None)
% Saves joint moment data to .sto files.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function saveMtpMuscleModelParameters(mtpInputs, finalValues, ...
    precalInputs, resultsDirectory)
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
columnLabels = mtpInputs.muscleNames;

if isfield(precalInputs, "useAbsoluteLengths") && precalInputs.useAbsoluteLengths
    dataPoints = [finalValues.activationTimeConstants;
        finalValues.activationNonlinearityConstants;
        finalValues.electromechanicalDelays;
        finalValues.emgScaleFactors;
        precalInputs.optimalFiberLength - mtpInputs.optimalFiberLength;
        precalInputs.tendonSlackLength - mtpInputs.tendonSlackLength];
else
    dataPoints = [finalValues.activationTimeConstants;
        finalValues.activationNonlinearityConstants;
        finalValues.electromechanicalDelays;
        finalValues.emgScaleFactors;
        finalValues.optimalFiberLengthScaleFactors;
        finalValues.tendonSlackLengthScaleFactors];
end
writeToSto(columnLabels, 1:1:size(dataPoints,1), dataPoints, ...
    fullfile(resultsDirectory, "muscleModelParameters.sto"));
end