function [outputArg1,outputArg2] = computeMuscleTendonCostFunction(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% inputArg1 = guess
% inputArg2 = parameters structure


% load parameters

% Write computeMuscleActivations

[muscleActivations, muscleExcitations] = computeMuscleActivations(inputArg2);

% Write computeMuscleMomentAndLength

[modelJointMoments, lmtilda, vmtilda, ...
    modelMomentArms, muscleMoments, Lmt, ...
    muscleForces, VmT, Fmax] = computeMuscleMomentAndLength(inputArg2);



outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

