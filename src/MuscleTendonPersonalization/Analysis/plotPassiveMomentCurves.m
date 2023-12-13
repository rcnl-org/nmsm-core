function plotPassiveMomentCurves(resultsDirectory)
[momentNames, passiveMomentsExperimental] = extractSavedData( ...
    resultsDirectory, "passiveJointMomentsExperimental");
[~, passiveMomentsModel] = extractSavedData( ...
    resultsDirectory, "passiveJointMomentsModeled");
momentNames = strrep(momentNames, '_', ' ');
meanPassiveMomentsExperimental = mean(passiveMomentsExperimental, 3);
stdPassiveMomentsExperimental = std(passiveMomentsExperimental, [], 3);
meanPassiveMomentsModel = mean(passiveMomentsModel, 3);
stdPassiveMomentsModel = std(passiveMomentsModel, [], 3);
maxMoment = max([max(meanPassiveMomentsExperimental, [], 'all'), ...
    max(meanPassiveMomentsModel, [], 'all')]);
minMoment = min([min(meanPassiveMomentsExperimental, [], 'all'), ...
    min(meanPassiveMomentsModel, [], 'all')]);

numWindows = ceil(sqrt(numel(momentNames)));
t = 1:1:size(meanPassiveMomentsModel,1);
figure(Name = "Passive Moment Curves", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])

for i = 1:numel(momentNames)
    subplot(numWindows, numWindows, i)
    hold on

    plot(meanPassiveMomentsExperimental(:,i), 'b-', linewidth=2)
    plot(meanPassiveMomentsModel(:,i), 'r-', linewidth=2)

    fillRegionExperimental = [(meanPassiveMomentsExperimental(:,i)+stdPassiveMomentsExperimental(:,i));
        flipud((meanPassiveMomentsExperimental(:,i)-stdPassiveMomentsExperimental(:,i)))];
    fill([t, fliplr(t)]', fillRegionExperimental, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    fillRegionModel = [(meanPassiveMomentsModel(:,i)+stdPassiveMomentsModel(:,i));
        flipud((meanPassiveMomentsModel(:,i)-stdPassiveMomentsModel(:,i)))];
    fill([t, fliplr(t)]', fillRegionModel, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    hold off
    set(gca, fontsize=11)
    title(momentNames(i), FontSize=12)
    axis([1 size(meanPassiveMomentsModel, 1) minMoment maxMoment])
    if mod(i,4) == 1
        ylabel("Moment [Nm]")
    end
    if i>numel(momentNames)-numWindows
        xlabel("Time Points")
    end
end
end

