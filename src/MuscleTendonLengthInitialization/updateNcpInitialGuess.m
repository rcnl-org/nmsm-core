function ncpInputs = updateNcpInitialGuess(ncpInputs, ...
    precalInputs, optimizedInitialGuess)
values = makeMuscleTendonLengthInitializationValuesAsStruct( ...
    optimizedInitialGuess, precalInputs);
nonMtpEntries = ismember(ncpInputs.muscleNames, ...
    ncpInputs.mtpActivationsColumnNames);
ncpInputs.optimalFiberLength(nonMtpEntries) = ...
    precalInputs.optimalFiberLength(nonMtpEntries) ...
    .* values.optimalFiberLengthScaleFactors(nonMtpEntries);
ncpInputs.tendonSlackLength(nonMtpEntries) = ...
    precalInputs.tendonSlackLength(nonMtpEntries) .* ...
    values.tendonSlackLengthScaleFactors(nonMtpEntries);
newMaxIsometricForce = getMaxIsometricForce(precalInputs, values);
ncpInputs.maxIsometricForce(nonMtpEntries) = ...
    newMaxIsometricForce(nonMtpEntries);
end
