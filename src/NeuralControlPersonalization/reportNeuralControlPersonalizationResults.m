

function reportNeuralControlPersonalizationResults(finalValues, inputs, params)

% Save solution
if not(isfolder(fullfile(pwd, "result")))
    mkdir(fullfile(pwd, "result"))
end
save(fullfile(pwd, 'result', inputs.savefilename + ".mat"), 'finalValues');

% Reconstruct activation values
activations = calcActivationsFromSynergyDesignVariables(finalValues, inputs, params);

% Calculate muscle-tendon forces from optimal activations
for i = 1:inputs.numPoints
    for k = 1:inputs.numMuscles
        [FMTVals(i, k), FTPassive(i, k)] = calcMuscleTendonForce(activations(i, k), inputs.muscleTendonLength(i, k), inputs.muscleTendonVelocity(i, k), k, inputs);
    end
end

fprintf('Maximum estimated muscle activation is %f\n', max(max(activations)));

% Plot activations and musce-ltendon forces
plotMuscleActivations(activations, inputs.muscleNames, inputs)
% plotMuscleForces(FMTVals, inputs.muscleNames,inputs) % can be added

% Plot joint torque results
plotTorques(activations, inputs.coordinateNames, inputs)

% plot synergy variables
[C, W] = unpackDesignVariables(finalValues, inputs, params);
plotSynergies(C, W, inputs);

end

