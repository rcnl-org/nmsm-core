function savePassiveForceData(mtpInputs, modeledValues, results, resultsSynx, ...
    resultsSynxNoResiduals, resultsDirectory)
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    modeledValues.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesExperimental"), "_passiveForcesExperimental.sto");
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    results.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesModel"), "_passiveForcesModel.sto");
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    resultsSynx.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesModelSynx"), "_passiveForcesModelSynx.sto");
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    resultsSynxNoResiduals.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesModelSynxNoResiduals"), "_passiveForcesModelSynxNoResiduals.sto");
end
