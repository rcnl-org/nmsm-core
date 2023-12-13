function saveMuscleModelParameters(mtpInputs, finalValues, resultsDirectory)
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
columnLabels = mtpInputs.muscleNames;
dataPoints = [finalValues.activationTimeConstants;
    finalValues.activationNonlinearityConstants;
    finalValues.electromechanicalDelays;
    finalValues.emgScaleFactors;
    finalValues.optimalFiberLengthScaleFactors;
    finalValues.tendonSlackLengthScaleFactors];
writeToSto(columnLabels, 1:1:size(dataPoints,1), dataPoints, ...
    fullfile(resultsDirectory, "muscleModelParameters.sto"));
end