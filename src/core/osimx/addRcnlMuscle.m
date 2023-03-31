function osimx = addRcnlMuscle(osimx, muscleName, muscleParameters)

muscleSet = osimx.NMSMPipelineDocument.OsimxModel.RCNLMuscleSet;

index = muscleSet.objects.RCNLMuscle

muscleSet.objects.RCNLMuscle{end + 1}

end

