markerNames.toe = "R.Toe";
markerNames.heel = "R.Heel";
markerNames.lateral = "R.Lateral";
markerNames.medial = "R.Medial";

markerFieldNames = fieldnames(markerNames);


%% Test simple calcFootMarkerPositionAndSlopeError

inputs.markerNames.toe = markerNames.toe;
markerFieldNames = fieldnames(markerNames);
inputs.experimentalMarkerPositions.(markerFieldNames{1}) = [1 2 3];
inputs.experimentalMarkerVelocities.(markerFieldNames{1}) = [1 1 1];
modeledValues.markerPositions.(markerFieldNames{1}) = [1.5 2.3 3.1];
modeledValues.markerVelocities.(markerFieldNames{1}) = [0.8 0.8 0.8];

[valueError, slopeError] = calcFootMarkerPositionAndSlopeError(inputs, modeledValues);

assertWithinRange(valueError .^ 2, [0.5 0.3 0.1] .^ 2, 0.001);
assertWithinRange(slopeError .^ 2, [0.2 0.2 0.2] .^ 2, 0.001);