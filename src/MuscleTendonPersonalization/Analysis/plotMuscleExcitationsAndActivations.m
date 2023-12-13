function plotMuscleExcitationsAndActivations(resultsDirectory)
[muscleNames, excitations] = extractSavedData( ...
    resultsDirectory, "muscleExcitations");
[~, activations] = extractSavedData( ...
    resultsDirectory, "muscleActivations");
[~, excitationsSynx] = extractSavedData( ...
    resultsDirectory, "muscleExcitationsSynx");
[~, activationsSynx] = extractSavedData( ...
    resultsDirectory, "muscleActivationsSynx");
muscleNames = strrep(muscleNames, '_', ' ');
meanExcitations = mean(excitations, 3);
stdExcitations = std(excitations,[], 3);
meanActivations = mean(activations, 3);
stdActivations = std(activations,[], 3);
meanExcitationsSynx = mean(excitationsSynx, 3);
stdExcitationsSynx = std(excitationsSynx,[], 3);
meanActivationsSynx = mean(activationsSynx, 3);
stdActivationsSynx = std(activationsSynx,[], 3);

figure(Name = "Muscle Excitations and Activations", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])

t = 1:1:size(meanExcitations,1);
numWindows = ceil(sqrt(numel(muscleNames)));
for i = 1:numel(muscleNames)
    subplot(numWindows, numWindows, i);
    hold on
    plot(meanExcitations(:,i), 'b-', linewidth=2)
    plot(meanExcitationsSynx(:,i), 'b--', linewidth=2)
    plot(meanActivations(:,i), 'r-', linewidth=2)
    plot(meanActivationsSynx(:,i), 'r--', linewidth=2)

    excitationFillRegion = [(meanExcitations(:,i)+stdExcitations(:,i)); ...
        flipud((meanExcitations(:,i)-stdExcitations(:,i)))];
    fill([t, fliplr(t)]', excitationFillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

    excitationSynxFillRegion = [(meanExcitationsSynx(:,i)+stdExcitationsSynx(:,i)); ...
        flipud((meanExcitationsSynx(:,i)-stdExcitationsSynx(:,i)))];
    fill([t, fliplr(t)]', excitationSynxFillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

    activationFillRegion = [(meanActivations(:,i)+stdActivations(:,i)); ...
        flipud((meanActivations(:,i)-stdActivations(:,i)))];
    fill([t, fliplr(t)]', activationFillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

    activationSynxFillRegion = [(meanActivationsSynx(:,i)+stdActivationsSynx(:,i)); ...
        flipud((meanActivationsSynx(:,i)-stdActivationsSynx(:,i)))];
    fill([t, fliplr(t)]', activationSynxFillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    set(gca, fontsize=11)
    axis([1 size(meanExcitations, 1) 0 1])
    title(muscleNames(i), FontSize=12);
    if i == 1
        legend ('Excitation(without residual)', ...
            'Excitation(with residual)', ...
            'Activation(without residual)', ...
            'Activation(with residual)');
    end
    if mod(i,3) == 1
        ylabel("Magnitude")
    end
    if i>numel(muscleNames)-numWindows
        xlabel("Time Points")
    end
end
end