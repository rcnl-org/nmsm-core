function plotMuscleActivations(activations, MuscLabels, inputs, params)

% Plot activation results
rightLegMuscleIndices = 1:inputs.numLegMuscles / 2;
leftLegMuscleIndices = inputs.numLegMuscles / 2 + 1:inputs.numLegMuscles;
rightTrunkMuscleIndices = inputs.numLegMuscles + 1:inputs.numLegMuscles + inputs.numTrunkMuscles / 2;
leftTrunkMuscleIndices = inputs.numLegMuscles + inputs.numTrunkMuscles / 2 + 1:inputs.numLegMuscles + inputs.numTrunkMuscles;

if ~isempty(activations)
    figure('Name', 'Right Leg Activations');
    for i = rightLegMuscleIndices
        subplot(5, 9, i), plot(inputs.NCPtimePercent, activations(:, i)); hold all;
        plot(inputs.NCPtimePercent, inputs.emgActivation(:, i));
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])
        if rem(i, 9) == 1
            ylabel('Activation');
        end
        if i == 9
            legend('NCP', 'EMG')
        end
    end

    % title('Right Leg')
    figure('Name', 'Left Leg Activations');

    for i = leftLegMuscleIndices
        subplot(5, 9, i - rightLegMuscleIndices(end)), plot(inputs.NCPtimePercent, activations(:, i)); hold all;
        plot(inputs.NCPtimePercent, inputs.emgActivation(:, i));
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])
        if rem(i, 9) == 1
            ylabel('Activation');
        end
        if i == 54
            legend('NCP', 'EMG')
        end
    end

    % title('Left Leg')
    figure('Name', 'Right Trunk Activations');

    for i = rightTrunkMuscleIndices
        subplot(5, 9, i - leftLegMuscleIndices(end)), plot(inputs.NCPtimePercent, activations(:, i)); hold all;
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])

        if rem(i, 9) == 1
            ylabel('Activation');
        end

    end

    % title('Right Trunk')
    figure('Name', 'Left Trunk Activations');

    for i = leftTrunkMuscleIndices
        subplot(5, 9, i - rightTrunkMuscleIndices(end)), plot(inputs.NCPtimePercent, activations(:, i)); hold all;
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])

        if rem(i, 9) == 1
            ylabel('Activation');
        end
    end
end
end

