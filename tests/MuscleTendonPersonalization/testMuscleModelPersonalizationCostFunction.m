%% Core Cost Function Testing
load('costFunctionTesting.mat')

hillTypeParams.lMt = params.lMt;
hillTypeParams.vMt = params.vMt;
hillTypeParams.vMaxFactor = params.vMaxFactor;
hillTypeParams.pennationAngle = params.pennationAngle;
hillTypeParams.fMax = params.fMax;
hillTypeParams.lMo = params.lMo;
hillTypeParams.lTs = params.lTs;

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
valuesStruct.primaryValues(5, :) = 1; % lmo scale factor
valuesStruct.primaryValues(6, :) = 1; % lts scale factor

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

[lMtilda, vMtilda] = ...
    calcNormalizedMusceFiberLengthsAndVelocities(hillTypeParams, ...
    valuesStruct);

load('normalizedMuscleLengthandVelocities.mat')
assertWithinRange(lMtilda, lMtildaExpected,0.001)
assertWithinRange(vMtilda, vMtildaExpected,0.001)

[passiveForce, muscleForce, muscleMoments, modelMoments] = ...
    calcMuscleMomentsAndForces(params.momentArms, hillTypeParams, ...
    muscleActivations, valuesStruct);

load('muscleMomentsAndForces.mat')
assertWithinRange(passiveForce, passiveForceExpected,0.001)
assertWithinRange(muscleForce, muscleForceExpected,0.001)
assertWithinRange(muscleMoments, muscleMomentsExpected,0.001)
assertWithinRange(modelMoments, modelMomentsExpected,0.001)

