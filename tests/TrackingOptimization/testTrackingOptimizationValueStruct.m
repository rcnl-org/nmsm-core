load('trackingOptimizationContinuousInputsAndValues.mat')

values = getTrackingOptimizationValueStruct(inputs.phase, inputs.auxdata);

expectedValues = load('expectedValues.mat');
assertWithinRange(values.time, expectedValues.time, 1e-12);
expectedValues.synergyWeights = getSynergyWeightsFromGroups(expectedValues.synergyWeights, inputs.auxdata);
assertWithinRange(values.synergyWeights, expectedValues.synergyWeights, 1e-5);
assertWithinRange(values.statePositions, expectedValues.statePositions, 1e-12);
assertWithinRange(values.stateVelocities, expectedValues.stateVelocities, 1e-12);
assertWithinRange(values.stateAccelerations, expectedValues.stateAccelerations, 1e-12);
assertWithinRange(values.controlJerks, expectedValues.controlJerks, 1e-12);
assertWithinRange(values.controlNeuralCommands, expectedValues.controlNeuralCommands, 1e-12);