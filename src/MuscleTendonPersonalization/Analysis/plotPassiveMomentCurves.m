function plotPassiveMomentCurves(resultsDirectory)
[momentNames, passiveMomentsExperimental] = extractSavedData(resultsDirectory, "passiveJointMomentsExperimental");
[~, passiveMomentsModel] = extractSavedData(resultsDirectory, "passiveJointMomentsModeled");

meanPassiveMomentsExperimental = mean(passiveMomentsExperimental, 3);
stdPassiveMomentsExperimental = std(passiveMomentsExperimental, [], 3);
meanPassiveMomentsModel = mean(passiveMomentsModel, 3);
stdPassiveMomentsModel = std(passiveMomentsModel, [], 3);
maxMoment = max([max(meanPassiveMomentsExperimental, [], 'all'), ...
    max(meanPassiveMomentsModel, [], 'all')]);
minMoment = min([min(meanPassiveMomentsExperimental, [], 'all'), ...
    min(meanPassiveMomentsModel, [], 'all')]);

% data.mean = {meanPassiveMomentsExperimental, meanPassiveMomentsModel};
% data.std = {stdPassiveMomentsExperimental, stdPassiveMomentsModel};
% data.labels = momentNames;
% 
% plotOptions.colors = ["b-", "r-"];
% plotOptions.legend = ["Experimental", "Model"];
% plotOptions.axisLimits = [1 size(meanPassiveMomentsModel, 1) minMoment maxMoment];
% plotOptions.xlabel = "Time Points";
% plotOptions.ylabel = "Moment [Nm]";
% 
% plotMtpData(data, plotOptions);

numWindows = ceil(sqrt(numel(momentNames)));
t = 1:1:size(meanPassiveMomentsModel,1);
figure()
set(gcf,'Position',[750,400,950,700])

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

    axis([1 size(meanPassiveMomentsModel, 1) minMoment maxMoment])
end

end

