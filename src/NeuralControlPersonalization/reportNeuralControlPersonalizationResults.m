

function reportNeuralControlPersonalizationResults(x, inputs, params)

% Save solution
if not(isfolder(fullfile(pwd, "result")))
    mkdir(fullfile(pwd, "result"))
end
save(fullfile(pwd, 'result', inputs.savefilename + ".mat"), 'x');

% Reconstruct activation values
activations = calcActivationsFromSynergyDesignVariables(x, inputs, params);

% Calculate muscle-tendon forces from optimal activations
for i5 = 1:inputs.numPoints
    for k2 = 1:inputs.numMuscles
        [FMTVals(i5, k2), FTPassive(i5, k2)] = calcMuscleTendonForce(activations(i5, k2), inputs.muscleTendonLength(i5, k2), inputs.muscleTendonVelocity(i5, k2), k2, inputs);
    end
end

fprintf('Maximum estimated muscle activation is %f\n', max(max(activations)));

% Plot activations and musce-ltendon forces
plotMuscleActivations(activations, inputs.muscleNames, inputs)
% plotMuscleForces(FMTVals, inputs.muscleNames,inputs) % can be added

% Plot joint torque results
plotTorques(activations, inputs.coordinateNames, inputs)

% plot synergy variables
[C, W] = unpackDesignVariables(x, inputs, params);
plotSynergies(C, W, inputs);

end

