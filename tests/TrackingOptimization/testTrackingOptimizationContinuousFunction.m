% break up tests to different functions
load('trackingOptimizationContinuousInputs.mat')
pointKinematics('exampleModel.osim');
inverseDynamics('exampleModel.osim');

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

phaseout = calcTrackingOptimizationTorqueBasedModeledValues(values, inputs.auxdata);

expectedPhaseout = load('expectedPhaseout.mat');
assertWithinRange(phaseout.bodyLocations.rightHeel, expectedPhaseout.bodyLocations(:,1:3), 1e-12);
assertWithinRange(phaseout.bodyLocations.rightToe, expectedPhaseout.bodyLocations(:,4:6), 1e-12);
assertWithinRange(phaseout.bodyLocations.leftHeel, expectedPhaseout.bodyLocations(:,7:9), 1e-12);
assertWithinRange(phaseout.bodyLocations.leftToe, expectedPhaseout.bodyLocations(:,10:12), 1e-12);
assertWithinRange(phaseout.bodyLocations.rightMidfootSuperior(:,[1 3]), expectedPhaseout.bodyLocations(:,[13 15]), 1e-12);
assertWithinRange(phaseout.bodyLocations.leftMidfootSuperior(:,[1 3]), expectedPhaseout.bodyLocations(:,[16 18]), 1e-12);
assertWithinRange(phaseout.rightGroundReactionsLab, expectedPhaseout.rightGroundReactionsLab, 1e-10);
assertWithinRange(phaseout.leftGroundReactionsLab, expectedPhaseout.leftGroundReactionsLab, 1e-10);
assertWithinRange(phaseout.inverseDynamicMoments, expectedPhaseout.inverseDynamicMoments, 1e-10);
assertWithinRange(phaseout.rootSegmentResiduals, expectedPhaseout.rootSegmentResiduals, 1e-10);
assertWithinRange(phaseout.muscleActuatedMoments, expectedPhaseout.muscleActuatedMoments, 1e-9);

phaseout = calcTrackingOptimizationSynergyBasedModeledValues(values, inputs.auxdata, phaseout);
assertWithinRange(phaseout.normalizedFiberLength, expectedPhaseout.normalizedFiberLength, 1e-5);
assertWithinRange(phaseout.normalizedFiberVelocity, expectedPhaseout.normalizedFiberVelocity, 1e-5);
assertWithinRange(phaseout.muscleActivations, expectedPhaseout.muscleActivations, 1e-5);
assertWithinRange(phaseout.muscleJointMoments, expectedPhaseout.muscleJointMoments, 1e-3);

phaseout.dynamics = calcTrackingOptimizationDynamicsConstraint(values, inputs.auxdata);

expectedDynamics = load('expectedDynamics.mat');
assertWithinRange(phaseout.dynamics, expectedDynamics.dynamics, 1e-6);

phaseout.path = calcTrackingOptimizationPathConstraint(phaseout, inputs.auxdata);

expectedPath = load('expectedPath.mat');
assertWithinRange(phaseout.path, expectedPath.path, 1e-2);

phaseout.integrand = calcTrackingOptimizationIntegrand(values, inputs.auxdata, ...
    phaseout);

expectedIntegrand = load('expectedIntegrand.mat');
assertWithinRange(phaseout.integrand, expectedIntegrand.integrand, 1e-3);