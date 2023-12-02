function plotJointMoments(resultsDirectory)
    [jointLabels, idMoments] = extractSavedData(resultsDirectory, "inverseDynamicsJointMoments");
    [~, noResidualMoments] = extractSavedData(resultsDirectory, "modelJointMomentsNoSynx");
    [~, withResidualMoments] = extractSavedData(resultsDirectory, "modelJointMomentsSynx");
    jointLabels = strrep(jointLabels, '_', ' ');
    meanIdMoments = mean(idMoments, 3);
    stdIdMoments = std(idMoments, [], 3);
    meanNoResidualMoments = mean(noResidualMoments, 3);
    stdNoResidualMoments = std(noResidualMoments, [], 3);
    meanWithResidualMoments = mean(withResidualMoments, 3);
    stdWithResidualMoments = std(withResidualMoments, [], 3);
    maxMoment = max([max(meanIdMoments, [], "all"), max(meanNoResidualMoments, [], "all") ...
        max(meanWithResidualMoments, [], "all")]);
    minMoment = min([min(meanIdMoments, [], "all"), min(meanNoResidualMoments, [], "all") ...
        min(meanWithResidualMoments, [], "all")]);

    % meanModelMoments = [meanNoResidualMoments, meanWithResidualMoments];
    % stdModelMoments = [stdNoResidualMoments, stdWithResidualMoments]; 
    % meanIdMoments = [meanIdMoments, meanIdMoments]; %Just reformat for plotting purpose.
    % stdIdMoments = [stdIdMoments, stdIdMoments];
    
    % data.mean = {meanModelMoments, meanIdMoments};
    % data.std = {stdModelMoments, stdIdMoments};
    % data.labels = [jointLabels jointLabels];
    % plotOptions.axisLimits = [1 size(meanIdMoments, 1) minMoment maxMoment];
    % plotOptions.colors = ["b-", "r-"];
    % plotOptions.xlabel = "Time Points";
    % plotOptions.ylabel = "Joint Moment [Nm]";
    % 
    % plotMtpData(data, plotOptions)

    figure(Name = "Joint Moments")
    sgtitle("Joint Moments", Fontsize=14)
    set(gcf, Position=[750,400,1050,800])
    t = 1:1:size(meanIdMoments,1);
    numWindows = numel(jointLabels);
    for i=1:numel(jointLabels)
        subplot(2, numWindows, i);
        hold on
        plot(meanNoResidualMoments(:,i), 'r-', linewidth=2)
        plot(meanIdMoments(:,i), 'b-', linewidth=2)

        noResidualFillRegion = [(meanNoResidualMoments(:,i)+stdNoResidualMoments(:,i));
            flipud(meanNoResidualMoments(:,i)-stdNoResidualMoments(:,i))];
        idFillRegion = [(meanIdMoments(:,i)+stdIdMoments(:,i));
            flipud(meanIdMoments(:,i)-stdIdMoments(:,i))];
        fill([t, fliplr(t)]', noResidualFillRegion, 'r', FaceAlpha=0.2, ...
            EdgeColor='none', HandleVisibility='off')
        fill([t, fliplr(t)]', idFillRegion, 'r', FaceAlpha=0.2, ...
            EdgeColor='none', HandleVisibility='off')
        hold off
        title(jointLabels(i), fontsize=12)
        axis([0 size(meanIdMoments, 1) minMoment, maxMoment])
        if i == 1
            legend("Mean Moment No Residual", "Mean Inverse Dynamics Moment")
            ylabel("Joint Moment [Nm]")
        end
        subplot(2, numWindows, i+3)
        hold on
        plot(meanWithResidualMoments(:,i), 'r-', linewidth=2)
        plot(meanIdMoments(:,i), 'b-', linewidth=2)

        withResidualFillRegion = [(meanWithResidualMoments(:,i)+stdWithResidualMoments(:,i));
            flipud(meanWithResidualMoments(:,i)-stdWithResidualMoments(:,i))];
        idFillRegion = [(meanIdMoments(:,i)+stdIdMoments(:,i));
            flipud(meanIdMoments(:,i)-stdIdMoments(:,i))];
        fill([t, fliplr(t)]', withResidualFillRegion, 'r', FaceAlpha=0.2, ...
            EdgeColor='none', HandleVisibility='off')
        fill([t, fliplr(t)]', idFillRegion, 'r', FaceAlpha=0.2, ...
            EdgeColor='none', HandleVisibility='off')
        hold off
        set(gca, fontsize=11)
        title(jointLabels(i), FontSize=12)
        xlabel("Time Point")
        axis([0 size(meanIdMoments, 1) minMoment, maxMoment])
        if i == 1
            legend("Mean Moment With Residual", "Mean Inverse Dynamics Moment")
            ylabel("Joint Moment [Nm]")
        end
        
    end
end

