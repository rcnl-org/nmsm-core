%% Core Cost Function Testing Round 3
load('costFunctionTestingRound3.mat')

valuesStruct.isIncluded(1) = 1;
valuesStruct.isIncluded(2) = 1;
valuesStruct.isIncluded(3) = 1;
valuesStruct.isIncluded(4) = 1;
valuesStruct.isIncluded(5) = 1;
valuesStruct.isIncluded(6) = 1;

numMuscles = params.nMusc;
valuesStruct.primaryValues = zeros(6, numMuscles);
valuesStruct.primaryValues(1, :) = guess.Round3(1, ...
    1:numMuscles); % electromechanical delay
valuesStruct.primaryValues(2, :) = guess.Round3(1, ...
    numMuscles + 1:numMuscles * 2); % activation time
valuesStruct.primaryValues(3, :) = guess.Round3(1, ...
    numMuscles * 2 + 1:numMuscles * 3); % activation nonlinearity
valuesStruct.primaryValues(4, :) = guess.Round3(1, ...
    numMuscles * 3 + 1:numMuscles * 4); % EMG scale factors
valuesStruct.primaryValues(5, :) = guess.Round3(1, ...
    numMuscles * 4 + 1:numMuscles * 5); % lmo scale factor
valuesStruct.primaryValues(6, :) = guess.Round3(1, ...
    numMuscles * 5 + 1:end); % lts scale factor

valuesStruct.secondaryValues = [];
for i = 1:length(valuesStruct.isIncluded)
   if(valuesStruct.isIncluded(i))
       valuesStruct.secondaryValues = [valuesStruct.secondaryValues valuesStruct.primaryValues(i, :)];
   end
end

% Muscle Excitation Calculation

muscleExcitations = calcMuscleExcitations(params.timeEMG, ...
    params.EmgSplines, findCorrectMtpValues(1, valuesStruct), ...
    findCorrectMtpValues(4, valuesStruct));

load('muscleExcitationsExpected.mat')
assertWithinRange(muscleExcitations, muscleExcitationsExpected, 0.001)

% Neural Activation Calculation

neuralActivations = calcNeuralActivations(muscleExcitations, ...
    findCorrectMtpValues(2, valuesStruct), params.timeEMG, params.nPad);

load('neuralActivationsExpected.mat')
assertWithinRange(neuralActivations, neuralActivationsExpected, 0.001)

% Muscle Activation Calculation

muscleActivations = calcMuscleActivations(findCorrectMtpValues(3, ...   
    valuesStruct), neuralActivations);

load('muscleActivationsExpected.mat')
assertWithinRange(muscleActivations, muscleActivationsExpected,0.001)

% Normalized Muscle Fiber Lengths and Velocities Calculation

[lMtilda, vMtilda] = ...
    calcNormalizedMusceFiberLengthsAndVelocities(hillTypeParams, ...
    valuesStruct);

load('normalizedMuscleLengthandVelocitiesExpected.mat')
assertWithinRange(lMtilda, lMtildaExpected,0.001)
assertWithinRange(vMtilda, vMtildaExpected,0.001)

% Muscle Moments and Forces

[passiveForce, muscleForce, muscleMoments, modelMoments] = ...
    calcMuscleMomentsAndForces(params.momentArms, hillTypeParams, ...
    muscleActivations, valuesStruct);

load('muscleMomentsAndForcesExpected.mat')
assertWithinRange(passiveForce, passiveForceExpected,0.001)
assertWithinRange(muscleForce, muscleForceExpected,0.001)
assertWithinRange(muscleMoments, muscleMomentsExpected,0.001)
assertWithinRange(modelMoments, modelMomentsExpected,0.001)

%% Mtp Cost Calculation
load('costFunctionTestingRound3.mat')

valuesStruct.isIncluded(1) = 1;
valuesStruct.isIncluded(2) = 1;
valuesStruct.isIncluded(3) = 1;
valuesStruct.isIncluded(4) = 1;
valuesStruct.isIncluded(5) = 0;
valuesStruct.isIncluded(6) = 0;

valuesStruct.primaryValues = zeros(6, numMuscles);
valuesStruct.primaryValues(1, :) = guess.Round3(1, ...
    1:numMuscles); % electromechanical delay
valuesStruct.primaryValues(2, :) = guess.Round3(1, ...
    numMuscles + 1:numMuscles * 2); % activation time
valuesStruct.primaryValues(3, :) = guess.Round3(1, ...
    numMuscles * 2 + 1:numMuscles * 3); % activation nonlinearity
valuesStruct.primaryValues(4, :) = guess.Round3(1, ...
    numMuscles * 3 + 1:numMuscles * 4); % EMG scale factors
valuesStruct.primaryValues(5, :) = guess.Round3(1, ...
    numMuscles * 4 + 1:numMuscles * 5); % lmo scale factor
valuesStruct.primaryValues(6, :) = guess.Round3(1, ...
    numMuscles * 5 + 1:end); % lts scale factor

valuesStruct.secondaryValues = [];
for i = 1:length(valuesStruct.isIncluded)
   if(valuesStruct.isIncluded(i))
       valuesStruct.secondaryValues = [valuesStruct.secondaryValues valuesStruct.primaryValues(i, :)];
   end
end

[cost] = computeMuscleTendonCostFunction(valuesStruct, params);

load('costExpected.mat')
assertWithinRange(cost, costExpected,0.001)