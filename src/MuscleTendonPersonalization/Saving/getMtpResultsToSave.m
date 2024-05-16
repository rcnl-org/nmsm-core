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
    getMtpResultsToSave(params, mtpResults, precalInputs)
finalValues = makeMtpValuesAsStruct([], mtpResults.primaryValues, zeros(1, 7), mtpResults);
if nargin < 3
    modeledValues = [];
    precalInputs = [];
else
    updatedMaxIsometricForce = precalInputs.optimizeIsometricMaxForce;
    tempValues.optimalFiberLengthScaleFactors = ...
        mtpResults.optimalFiberLength ./ precalInputs.optimalFiberLength;
    tempValues.tendonSlackLengthScaleFactors = ...
        mtpResults.tendonSlackLength ./ precalInputs.tendonSlackLength;
    precalInputs.maxIsometricForce = mtpResults.maxIsometricForce;
    precalInputs.optimizeIsometricMaxForce = 0;
    modeledValues = calcMuscleTendonLengthInitializationModeledValues(tempValues, precalInputs);
    if updatedMaxIsometricForce
        finalValues.maxIsometricForce = mtpResults.maxIsometricForce;
    end
end

tempVarName = calcMtpModeledValues(finalValues, mtpResults, struct());
tempVarName.time = mtpResults.emgTime(:, mtpResults.numPaddingFrames + 1 : ...
    end - mtpResults.numPaddingFrames);
tempVarName.muscleExcitations = tempVarName.muscleExcitations(:, :, ...
    mtpResults.numPaddingFrames + 1 : end - mtpResults.numPaddingFrames);
if isfield(mtpResults, "synergyExtrapolation")
    resultsSynx = calcMtpSynXModeledValues(finalValues, mtpResults, params);
    resultsSynx.time = mtpResults.emgTime(:, mtpResults.numPaddingFrames + 1 : ...
        end - mtpResults.numPaddingFrames);
    resultsSynx.muscleExcitations = resultsSynx.muscleExcitations(:, :, ...
        mtpResults.numPaddingFrames + 1 : end - mtpResults.numPaddingFrames);
    finalValues.synergyWeights(mtpResults.numberOfExtrapolationWeights + 1 : end) = 0;
    resultsStruct = struct("results", tempVarName, ...
        "resultsSynx", resultsSynx);
else
    resultsStruct = struct("results", tempVarName);
end
if ~isempty(precalInputs)
finalOptimalFiberLength = ...
    finalValues.optimalFiberLengthScaleFactors .* mtpResults.optimalFiberLength;
finalValues.optimalFiberLengthScaleFactors = ...
    finalOptimalFiberLength ./ precalInputs.optimalFiberLength;
finalTendonSlackLength = ...
    finalValues.tendonSlackLengthScaleFactors .* mtpResults.tendonSlackLength;
finalValues.tendonSlackLengthScaleFactors = ...
    finalTendonSlackLength ./ precalInputs.tendonSlackLength;
end
end