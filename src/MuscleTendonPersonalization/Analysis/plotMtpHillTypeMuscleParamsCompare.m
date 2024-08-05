function plotMtpHillTypeMuscleParamsCompare(rightResultsDirectory, ...
    leftResultsDirectory)
    rightAnalysisDirectory = fullfile(rightResultsDirectory, "Analysis");
    leftAnalysisDirectory = fullfile(leftResultsDirectory, "Analysis");
    [muscleNames, rightParams] = extractMtpDataFromSto( ...
        fullfile(rightAnalysisDirectory, "muscleModelParameters"));
    [~, leftParams] = extractMtpDataFromSto( ...
        fullfile(leftAnalysisDirectory, "muscleModelParameters"));
    muscleNames = strrep(muscleNames, '_', ' ');
    figure(Name = strcat("Compare Muscle Model Parameters"), ...
        Units='normalized', ...
        Position=[0.05 0.05 0.9 0.85])

if any(rightParams(5, :)<=0) | any(rightParams(6,:)<0)
    paramLabels = ["Activation Time Constant", ...
        "Activation Nonlinearity", ...
        "Electromechanical Time Delay", ...
        "EMG Scaling Factor", ...
        "Optimal Fiber Length Absolute Change", ...
        "Tendon Slack Length Absolute Change"];
else
    paramLabels = ["Activation Time Constant", ...
        "Activation Nonlinearity", ...
        "Electromechanical Time Delay", ...
        "EMG Scaling Factor", ...
        "Optimal Fiber Length Scaling Factor", ...
        "Tendon Slack Length Scaling Factor"];
end

t = tiledlayout(1, 6, ...
    TileSpacing='Compact', Padding='Compact');

for i = 1 : numel(paramLabels)
    nexttile(i)
    barh(1:numel(muscleNames), [rightParams(i,:); leftParams(i,:)]);
    
    title(textwrap(paramLabels(i), 20), FontSize=12)
    if i == 1
        yticks(1:numel(muscleNames))
        yticklabels(muscleNames)
        legend("Right Leg", "Left Leg")
    else
        yticks([])
        yticklabels([])
    end
end
end

