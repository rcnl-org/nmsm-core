% break up tests to different functions
load('trackingOptimizationInputs.mat')

values = getTrackingOptimizationValueStruct(inputs.phase, inputs.auxdata);

expectedValues = load('expectedValues.mat');
assertWithinRange(values.time, expectedValues.time, 1e-12);
assertWithinRange(values.synergyWeights, expectedValues.synergyWeights, 1e-12);
assertWithinRange(values.statePositions, expectedValues.statePositions, 1e-12);
assertWithinRange(values.stateVelocities, expectedValues.stateVelocities, 1e-12);
assertWithinRange(values.stateAccelerations, expectedValues.stateAccelerations, 1e-12);
assertWithinRange(values.controlJerks, expectedValues.controlJerks, 1e-12);
assertWithinRange(values.controlNeuralCommandsRight, expectedValues.controlNeuralCommandsRight, 1e-12);
assertWithinRange(values.controlNeuralCommandsLeft, expectedValues.controlNeuralCommandsLeft, 1e-12);

phaseout = calcTrackingOptimizationTorqueBasedModeledValues(values, inputs.auxdata);

expectedPhaseout = load('expectedPhaseout.mat');
assertWithinRange(phaseout.bodyLocations.rightHeel, expectedPhaseout.bodyLocations(:,1:3), 1e-12);
assertWithinRange(phaseout.bodyLocations.rightToe, expectedPhaseout.bodyLocations(:,4:6), 1e-12);
assertWithinRange(phaseout.bodyLocations.leftHeel, expectedPhaseout.bodyLocations(:,7:9), 1e-12);
assertWithinRange(phaseout.bodyLocations.leftToe, expectedPhaseout.bodyLocations(:,10:12), 1e-12);
assertWithinRange(phaseout.bodyLocations.rightMidfootSuperior(:,[1 3]), expectedPhaseout.bodyLocations(:,[13 15]), 1e-12);
assertWithinRange(phaseout.bodyLocations.leftMidfootSuperior(:,[1 3]), expectedPhaseout.bodyLocations(:,[16 18]), 1e-12);
assertWithinRange(phaseout.rightGroundReactionsLab, expectedPhaseout.rightGroundReactionsLab, 1e-12);
assertWithinRange(phaseout.leftGroundReactionsLab, expectedPhaseout.leftGroundReactionsLab, 1e-12);
assertWithinRange(phaseout.inverseDynamicMoments, expectedPhaseout.inverseDynamicMoments, 1e-12);
assertWithinRange(phaseout.rootSegmentResiduals, expectedPhaseout.rootSegmentResiduals, 1e-12);
assertWithinRange(phaseout.muscleActuatedMoments, expectedPhaseout.muscleActuatedMoments, 1e-12);

phaseout = calcTrackingOptimizationSynergyBasedModeledValues(values, inputs.auxdata, phaseout);
assertWithinRange(phaseout.rightMuscleActivations, expectedPhaseout.rightMuscleActivations, 1e-12);
assertWithinRange(phaseout.leftMuscleActivations, expectedPhaseout.leftMuscleActivations, 1e-12);
% assertWithinRange(phaseout.muscleJointMoments, expectedPhaseout.muscleJointMoments, 1e-12);

phaseout.dynamics = calcTrackingOptimizationDynamicsConstraint(values, inputs.auxdata);

expectedDynamics = load('expectedDynamics.mat');
assertWithinRange(phaseout.dynamics, expectedDynamics.dynamics, 1e-12);

% phaseout.path = calcTrackingOptimizationPathConstraint(phaseout, inputs.auxdata);
% 
% expectedPath = load('expectedPath.mat');
% assertWithinRange(phaseout.path, expectedPath.path, 1e-12);
% 
% phaseout.integrand = calcTrackingOptimizationIntegrand(values, inputs.auxdata, ...
%     phaseout);
% 
% expectedIntegrand = load('expectedIntegrand.mat');
% assertWithinRange(phaseout.integrand, expectedIntegrand.integrand, 1e-12);