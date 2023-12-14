function [finalValues, resultsStruct, modeledValues] = ...
    getMtpResultsToSave(mtpInputs, params, optimizedParams, precalInputs)
finalValues = makeMtpValuesAsStruct([], optimizedParams, zeros(1, 7));
if nargin < 4
    modeledValues = [];
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

if precalInputs.optimizeIsometricMaxForce
    finalValues.maxIsometricForce = mtpInputs.maxIsometricForce;
end
results = calcMtpModeledValues(finalValues, mtpInputs, struct());
results.time = mtpInputs.emgTime(:, mtpInputs.numPaddingFrames + 1 : ...
    end - mtpInputs.numPaddingFrames);
results.muscleExcitations = results.muscleExcitations(:, :, ...
    mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
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