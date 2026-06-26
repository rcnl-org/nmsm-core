% This function is part of the NMSM Pipeline, see file for full license.
% 
% This function takes the input, finalValues, result structs and writes to
% the appropriate .osimx muscle model, .sto joint moments, .sto muscle 
% activations & excitations, .sto Hill-Type muscle-tendon model parameter, 
% .sto passive forces, and .sto passive moment files. The model is included 
% in instances where the results are relative to the original model, which 
% is used for reference.
%
% (struct, struct, struct, struct, string, struct) -> (None)
% Saves results in the struct to the given filenames

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond, Robert Salati               %
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

function saveMuscleTendonPersonalizationResults(mtpInputs, finalValues, ...
    modeledValues, resultsStruct, resultsDirectory, precalInputs)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
if exist(analysisDirectory, "dir")
    rmdir(analysisDirectory, 's')
end
if nargin < 6
    precalInputs = [];
end

if ~isempty(precalInputs)
    saveMtpPassiveMomentData(precalInputs, modeledValues, analysisDirectory);
end
saveMtpMuscleForceData(mtpInputs, resultsStruct, analysisDirectory)
saveMtpPassiveForceData(mtpInputs, resultsStruct, analysisDirectory);
saveMtpActivationAndExcitationData(mtpInputs, resultsStruct, analysisDirectory);
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    resultsStruct.results.normalizedFiberLength, ...
    resultsStruct.results.time, ...
    fullfile(analysisDirectory, "normalizedFiberLengths"), ...
    "_normalizedFiberLengths.sto")
saveMtpJointMomentData(mtpInputs, resultsStruct, analysisDirectory);
saveMtpMuscleModelParameters(mtpInputs, finalValues, ...
    precalInputs, fullfile(analysisDirectory, "muscleModelParameters"));
model = Model(mtpInputs.model);
muscleNames = getMusclesFromCoordinates(model, mtpInputs.coordinateNames);
writeMuscleTendonPersonalizationOsimxFile(mtpInputs.modelFileName, ...
    mtpInputs.osimxFileName, finalValues, muscleNames, resultsDirectory);
end