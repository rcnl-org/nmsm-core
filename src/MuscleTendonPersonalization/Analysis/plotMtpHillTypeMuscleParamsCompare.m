function plotMtpHillTypeMuscleParamsCompare(resultsDirectory1, ...
    resultsDirectory2)
analysisDirectory1 = fullfile(resultsDirectory1, "Analysis");
analysisDirectory2 = fullfile(resultsDirectory2, "Analysis");
[muscleNames, params1] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory1, "muscleModelParameters"));
[~, params2] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory2, "muscleModelParameters"));
muscleNames = strrep(muscleNames, '_', ' ');
figure(Name = strcat("Compare Muscle Model Parameters"), ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
colors = getPlottingColors();
if any(params1(5, :)<=0) | any(params1(6,:)<0)
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
    b = barh(1:numel(muscleNames), [params1(i,:); params2(i,:)]);
    b(1).FaceColor = colors(1);
    b(2).FaceColor = colors(2);
    title(textwrap(paramLabels(i), 20), FontSize=12)
    if i == 1
        yticks(1:numel(muscleNames))
        yticklabels(muscleNames)
        legend(resultsDirectory1, resultsDirectory2)
    else
        yticks([])
        yticklabels([])
    end
end
end

