function plotNormalizedFiberLengths(resultsDirectory)
    [muscleNames, normalizedFiberLengths] = extractSavedData( ...
        resultsDirectory, "normalizedFiberLengths");

    meanFiberLengths = mean(normalizedFiberLengths, 3);
    stdFiberLengths = std(normalizedFiberLengths, [], 3);

    figure()
    set(gcf,'Position',[750,400,950,700])
    t = 1:1:size(meanExcitations,1);
    numWindows = ceil(sqrt(numel(muscleNames)));
    passiveLower = ones(size(t))*0.7;
    passiveUpper = ones(size(t));

    for i=1:numel(muscleNames)
        
    end

end

