%% Core Cost Function Testing Round 1
clear
load('updatedTest.mat')

valuesStruct.electromechanicalDelays = ones(1, numMuscles) * 0.5; % electromechanical delay
valuesStruct.activationTimeConstants = ones(1, numMuscles) * 1.5; % activation time
valuesStruct.activationNonlinearityConstants = ones(1, numMuscles) * 0.05; % activation nonlinearity
valuesStruct.emgScaleFactors = ones(1, numMuscles) * 0.5; % EMG scale factors
valuesStruct.optimalFiberLengthScaleFactors = guess.Round1(1,numMuscles+1:end); % lmo scale factor
valuesStruct.tendonSlackLengthScaleFactors = guess.Round1(1,1:numMuscles); % lts scale factor

% % Muscle Excitation Calculation
% 
% muscleExcitations = calcMuscleExcitations(inputData.emgTime, ...
%     inputData.emgSplines, valuesStruct.electromechanicalDelays, ...
%     valuesStruct.emgScaleFactors);
% 
% muscleExcitationsExpected = load('muscleExcitationsExpected.mat').muscleExcitationsExpected;
% 
% muscleExcitationsExpected = permute(muscleExcitationsExpected, [2, 3, 1]);
% 
% % changed emgTime to 10x141 from 141x10
% % permuted results
% assertWithinRange(muscleExcitations, muscleExcitationsExpected, 0.0001)
% 
% % Neural Activation Calculation
% 
% neuralActivations = calcNeuralActivations(muscleExcitations, ...
%     valuesStruct.activationTimeConstants, inputData.emgTime, inputData.numPaddingFrames);
% 
% neuralActivationsExpected = load('neuralActivationsExpected.mat').neuralActivationsExpected;
% neuralActivationsExpected = permute(neuralActivationsExpected, [2, 3, 1]);
% 
% % required to update to 0.002 from 0.001 to pass
% assertWithinRange(neuralActivations, neuralActivationsExpected, 0.0001)
% 
% % Muscle Activation Calculation
% 
% muscleActivations = calcMuscleActivations(neuralActivations, valuesStruct.activationNonlinearityConstants);
% 
% muscleActivationsExpected = load('muscleActivationsExpected.mat').muscleActivationsExpected;
% muscleActivationsExpected = permute(muscleActivationsExpected, [2, 3, 1]);
% 
% % required to update to 0.0023 from 0.001 to pass
% assertWithinRange(muscleActivations, muscleActivationsExpected, 0.0001)
% 
% % Normalized Muscle Fiber Lengths and Velocities Calculation
% 
% [normalizedFiberLength, normalizedFiberVelocity] = ...
%     calcNormalizedMuscleFiberLengthsAndVelocities(inputData, ...
%     valuesStruct.optimalFiberLengthScaleFactors, ...
%     valuesStruct.tendonSlackLengthScaleFactors);
% 
% % save("round1test.mat")
% 
% lMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').lMtildaExpected;
% lMtildaExpected = permute(lMtildaExpected, [2, 3, 1]);
% vMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').vMtildaExpected;
% vMtildaExpected = permute(vMtildaExpected, [2, 3, 1]);
% assertWithinRange(normalizedFiberLength, lMtildaExpected, 0.0001)
% assertWithinRange(normalizedFiberVelocity, vMtildaExpected, 0.0001)
% 
% 
% % Muscle Moments and Forces
% 
% passiveForce = calcPassiveForceLengthCurve(normalizedFiberLength, inputData.maxIsometricForce, inputData.pennationAngle);
% 
% muscleJointMoments = calcMuscleJointMoments(inputData, ...
%     muscleActivations, normalizedFiberLength, ...
%     normalizedFiberVelocity);
% 
% load('muscleMomentsAndForcesExpected.mat')
% 
% passiveForceExpected = permute(passiveForceExpected, [2, 3, 1]);
% assertWithinRange(passiveForce, passiveForceExpected, 0.0001)
% % assertWithinRange(muscleForce, muscleForceExpected, 0.001)
% % assertWithinRange(muscleMoments, muscleMomentsExpected, 0.001)
% 
% muscleMomentsExpected = permute(muscleMomentsExpected, [2, 4, 3, 1]);
% assertWithinRange(muscleJointMoments, muscleMomentsExpected, 0.0001)

%%%%%%%%%%%%%%%%%%%%%%%% COST FN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modeledValues = calcMtpModeledValues(valuesStruct, inputData, struct());

expectedCost = load('individualCostsExpected.mat').individualCostsExpected;

momentTrackingCost = calcMomentTrackingCost(modeledValues, inputData, struct());
assertWithinRange(momentTrackingCost, sum(expectedCost.momentMatching .^ 2, "all"), 0.001)

% normalizedFiberLengthCost = calcNormalizedFiberLengthDeviationCost(modeledValues, inputData, struct());
% max(abs(normalizedFiberLengthCost - sum(expectedCost.lMtildaPenalty) .^ 2), [], 'all')
% assertWithinRange(normalizedFiberLengthCost, ...
%     sum(expectedCost.lMtildaPenalty) .^ 2, 0.001)
% 
% individualCosts = calcAllDeviationPenaltyCosts(valuesStruct, inputData,  ...
%     passiveForce, individualCosts);
% 
% assertWithinRange(individualCosts.activationTimePenalty, ...
%     individualCostsExpected.activationTimePenalty, 0.001)
% assertWithinRange(individualCosts.activationNonlinearityPenalty, ...
%     individualCostsExpected.activationNonlinearityPenalty, 0.001)
% assertWithinRange(individualCosts.lMoPenalty, ...
%     individualCostsExpected.lMoPenalty, 0.001)
% assertWithinRange(individualCosts.lTsPenalty, ...
%     individualCostsExpected.lTsPenalty, 0.001)
% assertWithinRange(individualCosts.emgScalePenalty, ...
%     individualCostsExpected.emgScalePenalty, 0.001)
% assertWithinRange(individualCosts.minPassiveForce, ...
%     individualCostsExpected.minPassiveForce, 0.001)
% 
% individualCosts = calcLmTildaCurveChangesCost(lMtilda, ...
%     inputData.lMtildaExperimental, inputData.lmtildaPairs, ...
%     inputData.errorCenters, inputData.maxAllowableErrors, individualCosts);
% 
% assertWithinRange(individualCosts.lmtildaPairedSimilarity, ...
%     individualCostsExpected.lmtildaPairedSimilarity, 0.001)
% 
% individualCosts = calcPairedMusclePenalties(valuesStruct, ...
%     inputData.activationPairs, inputData.errorCenters, ...
%     inputData.maxAllowableErrors, individualCosts);
% 
% assertWithinRange(individualCosts.emgScalePairedSimilarity, ...
%     individualCostsExpected.emgScalePairedSimilarity, 0.001)
% assertWithinRange(individualCosts.tdelayPairedSimilarity, ...
%     individualCostsExpected.tdelayPairedSimilarity, 0.001)
% 
% %% Mtp Cost Calculation
% load('costFunctionTestingRound1.mat')
% 
% valuesStruct.isIncluded(1) = 0;
% valuesStruct.isIncluded(2) = 0;
% valuesStruct.isIncluded(3) = 0;
% valuesStruct.isIncluded(4) = 0;
% valuesStruct.isIncluded(5) = 1;
% valuesStruct.isIncluded(6) = 1;
% 
% numMuscles = inputData.nMusc;
% valuesStruct.primaryValues = zeros(6, numMuscles);
% valuesStruct.primaryValues(1, :) = 0.5; % electromechanical delay
% valuesStruct.primaryValues(2, :) = 1.5; % activation time
% valuesStruct.primaryValues(3, :) = 0.05; % activation nonlinearity
% valuesStruct.primaryValues(4, :) = 0.5; % EMG scale factors
% valuesStruct.primaryValues(5, :) = guess.Round1(1,1:numMuscles); % lmo scale factor
% valuesStruct.primaryValues(6, :) = guess.Round1(1,numMuscles+1:end); % lts scale factor
% 
% valuesStruct.secondaryValues = [];
% for i = 1:length(valuesStruct.isIncluded)
%    if(valuesStruct.isIncluded(i))
%        valuesStruct.secondaryValues = [valuesStruct.secondaryValues ...
%            valuesStruct.primaryValues(i, :)];
%    end
% end
% 
% [cost] = computeMuscleTendonCostFunction(valuesStruct, inputData, params);
% 
% load('costExpected.mat')
% assertWithinRange(cost, costExpected, 0.001)