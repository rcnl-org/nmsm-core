function plotHillTypeMuscleParams(resultsDirectory)
[muscleNames, params] = extractSavedData( ...
    resultsDirectory, "muscleModelParameters");
muscleNames = strrep(muscleNames, '_', ' ');
figure(Name = "Muscle Model Parameters", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])

paramLabels = ["Activation Time Constant", ...
    "Activation Nonlinearity", ...
    "Electromechanical Time Delay", ...
    "EMG Scaling Factor", ...
    "Optimal Fiber Length Scaling Factor", ...
    "Tendon Slack Length Scaling Factor"];
for i = 1 : numel(paramLabels)
    subplot(1, 6, i)
    barh(params(i,:))

    title(textwrap(paramLabels(i), 20), FontSize=12)
    if i == 1
        set(gca, yticklabels = muscleNames, fontsize=11);
    else
        set(gca, yticklabels = [], fontsize=11);
    end
end
end

