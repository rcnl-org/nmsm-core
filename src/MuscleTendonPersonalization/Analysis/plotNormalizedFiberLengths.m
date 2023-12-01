function plotNormalizedFiberLengths(resultsDirectory)
    [muscleNames, normalizedFiberLengths] = extractSavedData( ...
        resultsDirectory, "normalizedFiberLengths");

    meanFiberLengths = mean(normalizedFiberLengths, 3);
    stdFiberLengths = std(normalizedFiberLengths, [], 3);

    figure()
    set(gcf,'Position',[750,400,950,700])
    t = 1:1:size(meanFiberLengths,1);
    numWindows = ceil(sqrt(numel(muscleNames)));
    passiveLower = ones(size(t))*0.7;
    passiveUpper = ones(size(t));

    for i=1:numel(muscleNames)
        subplot(numWindows, numWindows, i);
        hold on
        plot(meanFiberLengths(:,i), 'b-', LineWidth=2);

        fillRegion = [(meanFiberLengths(:,i)+stdFiberLengths(:,i)); 
            flipud(meanFiberLengths(:,i)-stdFiberLengths(:,i))];
        fill([t, fliplr(t)]', fillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

        plot(t, passiveUpper, 'r--', LineWidth=2);
        plot(t, passiveLower, 'r--', LineWidth=2);
        hold off

        axis([1 size(meanFiberLengths, 1) 0 1.5])
        
        title(muscleNames(i), FontSize=10, interpreter='latex');
        if mod(i,3) == 1
            ylabel("Normalized Fiber Length")
        end
        if i>numel(muscleNames)-numWindows
            xlabel("Time Points")
        end
    end

end

