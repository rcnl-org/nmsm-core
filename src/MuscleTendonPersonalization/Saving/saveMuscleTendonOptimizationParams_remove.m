% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves optimization results to .sto files to be plotted by
% the user in either MATLAB or Opensim
%
% (struct, struct, struct, string) -> (None)
% Saves MTP optimization parameters to .sto files to be plotted.
% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati, Di Ao, Marleny Vega                           %
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
function saveMuscleTendonOptimizationParams_remove(resultsDirectory, optimizedParams, ...
    mtpInputs, precalInputs)
if nargin < 4
    precalInputs = [];
end
[finalValues, results, resultsSynx, resultsSynxNoResiduals] = ...
    getValuesToSave(mtpInputs, optimizedParams);
if ~isempty(precalInputs)
    modeledValues = getMuscleTendonLengthInitializationData(precalInputs, ...
        mtpInputs);  % Modeled passive force data & params from experimental data.
    savePassiveMomentData(precalInputs, modeledValues, resultsDirectory);
    savePassiveForceData(mtpInputs, modeledValues, results, resultsSynx, ...
        resultsSynxNoResiduals, resultsDirectory);
end

saveActivationAndExcitationData(mtpInputs, results, resultsSynx, resultsDirectory);
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, results.normalizedFiberLength, ...
    fullfile(resultsDirectory, "normalizedFiberLengths"), "_normalizedFiberLengths.sto")
saveJointMomentData(mtpInputs, results, resultsSynx, resultsSynxNoResiduals, ...
    resultsDirectory);
saveMuscleModelParameters(mtpInputs, finalValues, fullfile(resultsDirectory, ...
    "muscleModelParameters"));
end

function [finalValues, results, resultsSynx, resultsSynxNoResiduals] = ...
    getValuesToSave(mtpInputs, optimizedParams)

finalValues = makeMtpValuesAsStruct([], optimizedParams, zeros(1, 7));
resultsSynx = calcMtpSynXModeledValues(finalValues, mtpInputs, struct());
finalValues.synergyWeights(mtpInputs.numberOfExtrapolationWeights + 1 : end) = 0;
resultsSynxNoResiduals = calcMtpSynXModeledValues(finalValues, mtpInputs, struct());
results = calcMtpModeledValues(finalValues, mtpInputs, struct());
results.time = mtpInputs.emgTime(:, mtpInputs.numPaddingFrames + 1 : ...
    end - mtpInputs.numPaddingFrames);
results.muscleExcitations = results.muscleExcitations(:, :, ...
    mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
resultsSynx.muscleExcitations = resultsSynx.muscleExcitations(:, :, ...
    mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
end

function modeledValues = getMuscleTendonLengthInitializationData(...
    precalInputs, mtpInputs)

tempValues.optimalFiberLengthScaleFactors = ...
    mtpInputs.optimalFiberLength ./ precalInputs.optimalFiberLength;

tempValues.tendonSlackLengthScaleFactors = ...
    mtpInputs.tendonSlackLength ./ precalInputs.tendonSlackLength;

precalInputs.maxIsometricForce = mtpInputs.maxIsometricForce;

precalInputs.optimizeIsometricMaxForce = 0;

modeledValues = calcMuscleTendonLengthInitializationModeledValues(tempValues, precalInputs);
end