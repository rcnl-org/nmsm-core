% function reportNeuralControlPersonalizationResults(settingsFileName)
% settingsTree = xml2struct(settingsFileName);
% [inputs, params, resultsDirectory] = ...
%     parseNeuralControlPersonalizationSettingsTree(settingsTree);
% optimizedParams = NeuralControlPersonalization(inputs, params);
% %% results is a structure, report not implemented yet
% results = calcFinalMuscleActivations(optimizedParams, inputs);
% results = calcFinalModelMoments(results, inputs);
% save("results.mat", "results", '-mat')
% % reportNeuralControlPersonalization(inputs.model, results)
% saveNeuralControlPersonalizationResults(inputs.model, ...
%     inputs.coordinates, results, resultsDirectory);

function reportNeuralControlPersonalizationResults(x, inputs, params)

CoordLabels = inputs.CoordLabels;

% Save solution
savefilename = inputs.savefilename;

if not(isfolder(fullfile(pwd, "result")))
    mkdir(fullfile(pwd, "result"))
end
save(fullfile(pwd, 'result', savefilename + ".mat"), 'x');

% Reconstruct activation values
aVals = calcActivationsFromSynergyDesignVariables(x, inputs, params);

% Calculate muscle-tendon forces from optimal activations
for i5 = 1:inputs.nPts
    for k2 = 1:inputs.numMuscles
        [FMTVals(i5, k2), FTPassive(i5, k2)] = calcMuscleTendonForce(aVals(i5, k2), inputs.muscleTendonLength(i5, k2), inputs.muscleTendonVelocity(i5, k2), k2, inputs);
    end
end

fprintf('Maximum estimated muscle activation is %f\n', max(max(aVals)));

% Plot activations and musce-ltendon forces
plotMuscleActivations(aVals, inputs.MuscNames, inputs)
% plotMuscleForces(FMTVals, inputs.MuscNames,inputs) % can be added

% Plot joint torque results
muscleJointMoments = zeros(inputs.nPts, inputs.nJoints);
% net moment
for i = 1:inputs.nPts
    for j = 1:inputs.nJoints
        for k = 1:inputs.numMuscles
            FMT = calcMuscleTendonForce(aVals(i, k), inputs.muscleTendonLength(i, k), inputs.muscleTendonVelocity(i, k), k, inputs);
            r = inputs.rVals(i, k, j);
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + r * FMT;
        end

    end

end

plotTorques(muscleJointMoments, CoordLabels, inputs)

% plot synergy variables
[C, W] = unpackDesignVariables(x, inputs, params);
plotSynergies(C, W, inputs);

end

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------


%--------------------------------------------------------------------------

