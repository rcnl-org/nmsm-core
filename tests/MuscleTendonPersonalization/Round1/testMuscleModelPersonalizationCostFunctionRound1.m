%% Core Cost Function Testing Round 1
load('costFunctionTestingRound1.mat')

valuesStruct.isIncluded(1) = 0;
valuesStruct.isIncluded(2) = 0;
valuesStruct.isIncluded(3) = 0;
valuesStruct.isIncluded(4) = 0;
valuesStruct.isIncluded(5) = 1;
valuesStruct.isIncluded(6) = 1;

numMuscles = params.nMusc;
valuesStruct.primaryValues = zeros(6, numMuscles);
valuesStruct.primaryValues(1, :) = 0.5; % electromechanical delay
valuesStruct.primaryValues(2, :) = 1.5; % activation time
valuesStruct.primaryValues(3, :) = 0.05; % activation nonlinearity
valuesStruct.primaryValues(4, :) = 0.5; % EMG scale factors
valuesStruct.primaryValues(5, :) = guess.Round1(1,1:numMuscles); % lmo scale factor
valuesStruct.primaryValues(6, :) = guess.Round1(1,numMuscles+1:end); % lts scale factor

valuesStruct.secondaryValues = [];
for i = 1:length(valuesStruct.isIncluded)
   if(valuesStruct.isIncluded(i))
       valuesStruct.secondaryValues = [valuesStruct.secondaryValues valuesStruct.primaryValues(i, :)];
   end
end

% Muscle Excitation Calculation

muscleExcitations = calcMuscleExcitations(data.emgTime, ...
    data.emgSplines, findCorrectMtpValues(1, valuesStruct), ...
    findCorrectMtpValues(4, valuesStruct));

load('muscleExcitationsExpected.mat')
assertWithinRange(muscleExcitations, muscleExcitationsExpected, 0.001)

% Neural Activation Calculation

neuralActivations = calcNeuralActivations(muscleExcitations, ...
    findCorrectMtpValues(2, valuesStruct), data.emgTime, data.numPaddingFrames);

load('neuralActivationsExpected.mat')
assertWithinRange(neuralActivations, neuralActivationsExpected, 0.001)

% Muscle Activation Calculation

muscleActivations = calcMuscleActivations(findCorrectMtpValues(3, ...   
    valuesStruct), neuralActivations);

load('muscleActivationsExpected.mat')
assertWithinRange(muscleActivations, muscleActivationsExpected,0.001)

% Normalized Muscle Fiber Lengths and Velocities Calculation

[lMtilda, vMtilda] = ...
    calcNormalizedMusceFiberLengthsAndVelocities(data, ...
    valuesStruct);

load('normalizedMuscleLengthandVelocitiesExpected.mat')
assertWithinRange(lMtilda, lMtildaExpected,0.001)
assertWithinRange(vMtilda, vMtildaExpected,0.001)

% Muscle Moments and Forces

[passiveForce, muscleForce, muscleMoments, modelMoments] = ...
    calcMuscleMomentsAndForces(data, ...
    muscleActivations, valuesStruct);

load('muscleMomentsAndForcesExpected.mat')
assertWithinRange(passiveForce, passiveForceExpected,0.001)
assertWithinRange(muscleForce, muscleForceExpected,0.001)
assertWithinRange(muscleMoments, muscleMomentsExpected,0.001)
assertWithinRange(modelMoments, modelMomentsExpected,0.001)

%% Mtp Cost Calculation
load('costFunctionTestingRound1.mat')

valuesStruct.isIncluded(1) = 0;
valuesStruct.isIncluded(2) = 0;
valuesStruct.isIncluded(3) = 0;
valuesStruct.isIncluded(4) = 0;
valuesStruct.isIncluded(5) = 1;
valuesStruct.isIncluded(6) = 1;

numMuscles = params.nMusc;
valuesStruct.primaryValues = zeros(6, numMuscles);
valuesStruct.primaryValues(1, :) = 0.5; % electromechanical delay
valuesStruct.primaryValues(2, :) = 1.5; % activation time
valuesStruct.primaryValues(3, :) = 0.05; % activation nonlinearity
valuesStruct.primaryValues(4, :) = 0.5; % EMG scale factors
valuesStruct.primaryValues(5, :) = guess.Round1(1,1:numMuscles); % lmo scale factor
valuesStruct.primaryValues(6, :) = guess.Round1(1,numMuscles+1:end); % lts scale factor

valuesStruct.secondaryValues = [];
for i = 1:length(valuesStruct.isIncluded)
   if(valuesStruct.isIncluded(i))
       valuesStruct.secondaryValues = [valuesStruct.secondaryValues valuesStruct.primaryValues(i, :)];
   end
end

[cost] = computeMuscleTendonCostFunction(valuesStruct, data, params);

load('costExpected.mat')
assertWithinRange(cost, costExpected,0.001)