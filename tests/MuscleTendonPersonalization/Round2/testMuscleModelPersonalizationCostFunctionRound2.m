%% Core Cost Function Testing Round 2
load('costFunctionTestingRound2.mat')

valuesStruct.isIncluded(1) = 1;
valuesStruct.isIncluded(2) = 1;
valuesStruct.isIncluded(3) = 1;
valuesStruct.isIncluded(4) = 1;
valuesStruct.isIncluded(5) = 0;
valuesStruct.isIncluded(6) = 0;

numMuscles = inputData.nMusc;
valuesStruct.primaryValues = zeros(6, numMuscles);
valuesStruct.primaryValues(1, :) = guess.Round2(1, ...
    1:numMuscles); % electromechanical delay
valuesStruct.primaryValues(2, :) = guess.Round2(1, ...
    numMuscles + 1:numMuscles * 2); % activation time
valuesStruct.primaryValues(3, :) = guess.Round2(1, ...
    numMuscles * 2 + 1:numMuscles * 3); % activation nonlinearity
valuesStruct.primaryValues(4, :) = guess.Round2(1, ...
    numMuscles * 3 + 1:end); % EMG scale factors
valuesStruct.primaryValues(5, :) = ltsscale; % lmo scale factor
valuesStruct.primaryValues(6, :) = lmoscale; % lts scale factor

valuesStruct.secondaryValues = [];
for i = 1:length(valuesStruct.isIncluded)
   if(valuesStruct.isIncluded(i))
       valuesStruct.secondaryValues = [valuesStruct.secondaryValues ...
           valuesStruct.primaryValues(i, :)];
   end
end

% Muscle Excitation Calculation

muscleExcitations = calcMuscleExcitations(inputData.timeEMG, ...
    inputData.emgSplines, findCorrectMtpValues(1, valuesStruct), ...
    findCorrectMtpValues(4, valuesStruct));

load('muscleExcitationsExpected.mat')
assertWithinRange(muscleExcitations, muscleExcitationsExpected, 0.001)

% Neural Activation Calculation

neuralActivations = calcNeuralActivations(muscleExcitations, ...
    findCorrectMtpValues(2, valuesStruct), inputData.timeEMG, inputData.nPad);

load('neuralActivationsExpected.mat')
assertWithinRange(neuralActivations, neuralActivationsExpected, 0.001)

% Muscle Activation Calculation

muscleActivations = calcMuscleActivations(findCorrectMtpValues(3, ...   
    valuesStruct), neuralActivations);

load('muscleActivationsExpected.mat')
assertWithinRange(muscleActivations, muscleActivationsExpected, 0.001)

% Normalized Muscle Fiber Lengths and Velocities Calculation

[lMtilda, vMtilda] = ...
    calcNormalizedMusceFiberLengthsAndVelocities(inputData, ...
    valuesStruct);

load('normalizedMuscleLengthandVelocitiesExpected.mat')
assertWithinRange(lMtilda, lMtildaExpected, 0.001)
assertWithinRange(vMtilda, vMtildaExpected, 0.001)

% Muscle Moments and Forces

[passiveForce, muscleForce, muscleMoments, modelMoments] = ...
    calcMuscleMomentsAndForces(inputData, muscleActivations, lMtilda, ...
    vMtilda);

load('muscleMomentsAndForcesExpected.mat')
assertWithinRange(passiveForce, passiveForceExpected, 0.001)
assertWithinRange(muscleForce, muscleForceExpected, 0.001)
assertWithinRange(muscleMoments, muscleMomentsExpected, 0.001)
assertWithinRange(modelMoments, modelMomentsExpected, 0.001)

%% Mtp Cost Calculation
load('costFunctionTestingRound2.mat')

valuesStruct.isIncluded(1) = 1;
valuesStruct.isIncluded(2) = 1;
valuesStruct.isIncluded(3) = 1;
valuesStruct.isIncluded(4) = 1;
valuesStruct.isIncluded(5) = 0;
valuesStruct.isIncluded(6) = 0;

numMuscles = inputData.nMusc;
valuesStruct.primaryValues = zeros(6, numMuscles);
valuesStruct.primaryValues(1, :) = guess.Round2(1, ...
    1:numMuscles); % electromechanical delay
valuesStruct.primaryValues(2, :) = guess.Round2(1, ...
    numMuscles + 1:numMuscles * 2); % activation time
valuesStruct.primaryValues(3, :) = guess.Round2(1, ...
    numMuscles * 2 + 1:numMuscles * 3); % activation nonlinearity
valuesStruct.primaryValues(4, :) = guess.Round2(1, ...
    numMuscles * 3 + 1:end); % EMG scale factors
valuesStruct.primaryValues(5, :) = ltsscale; % lmo scale factor
valuesStruct.primaryValues(6, :) = lmoscale; % lts scale factor

valuesStruct.secondaryValues = [];
for i = 1:length(valuesStruct.isIncluded)
   if(valuesStruct.isIncluded(i))
       valuesStruct.secondaryValues = [valuesStruct.secondaryValues ...
           valuesStruct.primaryValues(i, :)];
   end
end

[cost] = computeMuscleTendonCostFunction(valuesStruct, inputData, params);

load('costExpected.mat')
assertWithinRange(cost, costExpected, 0.001)