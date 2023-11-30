function plotPassiveForceCurves(resultsDirectory)
[muscleNames, passiveForce] = extractSavedData(resultsDirectory, "passiveForcesExperimental");

meanPassiveForce = mean(passiveForce, 3);
stdPassiveForce = std(passiveForce, [], 3);
maxForce = max(meanPassiveForce, [], 'all');
numWindows = ceil(sqrt(numel(muscleNames)));

% data.mean = {meanPassiveForce};
% data.std = {stdPassiveForce};
% data.labels = muscleNames;
% plotOptions.colors = ["b-"];
% plotOptions.axisLimits = [1 size(meanPassiveForce, 1), 0, maxForce];
% plotOptions.xlabel = "Time Points";
% plotOptions.ylabel = "Force [N]";
% 
% plotMtpData(data, plotOptions);

figure()
set(gcf,'Position',[750,400,950,700])
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
    axis([1 size(meanPassiveForce, 1) 0 maxForce])
    title(muscleNames(i), FontSize=10, interpreter='latex');
    if mod(i,3) == 1
        ylabel("Magnitude")
    end
    if i>numel(muscleNames)-numWindows
        xlabel("Time Points")
    end
end

