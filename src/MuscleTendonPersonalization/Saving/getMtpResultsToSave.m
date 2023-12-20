% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes MTP inputs and optimized muscle parameters and
% calculates normalized fiber length, passive force, passive moment, muscle
% activation, and muscle excitation curves to be later saved.
%
% (struct), (struct), (cell), (struct) -> (struct), (struct), (struct)
% Calculates relevant MTP curves

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

function [finalValues, resultsStruct, modeledValues] = ...
    getMtpResultsToSave(mtpInputs, params, optimizedParams, precalInputs)
finalValues = makeMtpValuesAsStruct([], optimizedParams, zeros(1, 7), mtpInputs);
if nargin < 4
    modeledValues = [];
    precalInputs = [];
else
    tempValues.optimalFiberLengthScaleFactors = ...
        mtpInputs.optimalFiberLength ./ precalInputs.optimalFiberLength;
    tempValues.tendonSlackLengthScaleFactors = ...
        mtpInputs.tendonSlackLength ./ precalInputs.tendonSlackLength;
    precalInputs.maxIsometricForce = mtpInputs.maxIsometricForce;
    precalInputs.optimizeIsometricMaxForce = 0;
    modeledValues = calcMuscleTendonLengthInitializationModeledValues(tempValues, precalInputs);
    if precalInputs.optimizeIsometricMaxForce
        finalValues.maxIsometricForce = mtpInputs.maxIsometricForce;
    end
end

results = calcMtpModeledValues(finalValues, mtpInputs, struct());
results.time = mtpInputs.emgTime(:, mtpInputs.numPaddingFrames + 1 : ...
    end - mtpInputs.numPaddingFrames);
results.muscleExcitations = results.muscleExcitations(:, :, ...
    mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
if isfield(mtpInputs, "synergyExtrapolation")
    resultsSynx = calcMtpSynXModeledValues(finalValues, mtpInputs, params);
    resultsSynx.time = mtpInputs.emgTime(:, mtpInputs.numPaddingFrames + 1 : ...
        end - mtpInputs.numPaddingFrames);
    resultsSynx.muscleExcitations = resultsSynx.muscleExcitations(:, :, ...
        mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
    finalValues.synergyWeights(mtpInputs.numberOfExtrapolationWeights + 1 : end) = 0;
    resultsSynxNoResiduals = calcMtpSynXModeledValues(finalValues, mtpInputs, struct());
    resultsStruct = struct("results", results, ...
        "resultsSynx", resultsSynx, ...
        "resultsSynxNoResiduals", resultsSynxNoResiduals);
else
    resultsStruct = struct("results", results);
end
if ~isempty(precalInputs)
finalOptimalFiberLength = ...
    finalValues.optimalFiberLengthScaleFactors .* mtpInputs.optimalFiberLength;
finalValues.optimalFiberLengthScaleFactors = ...
    finalOptimalFiberLength ./ precalInputs.optimalFiberLength;
finalTendonSlackLength = ...
    finalValues.tendonSlackLengthScaleFactors .* mtpInputs.tendonSlackLength;
finalValues.tendonSlackLengthScaleFactors = ...
    finalTendonSlackLength ./ precalInputs.tendonSlackLength;
end
end