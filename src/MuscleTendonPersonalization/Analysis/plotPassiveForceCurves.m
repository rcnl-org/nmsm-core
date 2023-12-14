function plotPassiveForceCurves(resultsDirectory)
[muscleNames, passiveForce] = extractMtpDataFromSto( ...
    resultsDirectory, "passiveForcesExperimental");
muscleNames = strrep(muscleNames, '_', ' ');
meanPassiveForce = mean(passiveForce, 3);
stdPassiveForce = std(passiveForce, [], 3);
maxForce = max(meanPassiveForce, [], 'all');
numWindows = ceil(sqrt(numel(muscleNames)));

figure(Name = "Passive Force Curves", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])
t = 1:1:size(meanPassiveForce,1);
for i = 1:numel(muscleNames)
    subplot(numWindows, numWindows, i)
    hold on
    plot(meanPassiveForce(:,i), 'b-', linewidth=2)

    fillRegion = [(meanPassiveForce(:,i)+stdPassiveForce(:,i));
        flipud((meanPassiveForce(:,i)-stdPassiveForce(:,i)))];
    fill([t, fliplr(t)]', fillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    hold off
    set(gca, fontsize=11)
    axis([1 size(meanPassiveForce, 1) 0 maxForce])
    title(muscleNames(i), FontSize=12);
    if mod(i,3) == 1
        ylabel("Magnitude")
    end
    if i>numel(muscleNames)-numWindows
        xlabel("Time Points")
    end
end

