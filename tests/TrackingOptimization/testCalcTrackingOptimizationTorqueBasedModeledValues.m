load('trackingOptimizationContinuousInputsAndValues.mat')

pointKinematics('exampleModel.osim');
inverseDynamics('exampleModel.osim');
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