function inputs = getMtpModelInputs(inputs)
inputs.optimalFiberLength = [];
inputs.tendonSlackLength = [];
inputs.pennationAngle = [];
inputs.maxIsometricForce = [];
model = Model(inputs.model);
for i = 1:length(inputs.muscleNames)
    muscleName = inputs.muscleNames(i);
    inputs.optimalFiberLength(end+1) = model.getForceSet(). ...
        getMuscles().get(muscleName).getOptimalFiberLength();
    inputs.tendonSlackLength(end+1) = model.getForceSet(). ...
        getMuscles().get(muscleName).getTendonSlackLength();
    inputs.pennationAngle(end+1) = model.getForceSet(). ...
        getMuscles().get(muscleName). ...
        getPennationAngleAtOptimalFiberLength();
    inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
        getMuscles().get(muscleName).getMaxIsometricForce();
    
end
end