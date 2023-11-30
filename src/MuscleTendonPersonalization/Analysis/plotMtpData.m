function plotMtpData(data, options)
    figure()
    set(gcf,'Position',[750,400,950,700])
    t = 1:1:size(data.mean{1},1);
    numWindows = ceil(sqrt(numel(data.labels)));
    for i = 1 : numel(data.labels)
        subplot(numWindows, numWindows, i);
        hold on
        for j = 1 : numel(data.mean)
            mean = data.mean{j};
            std = data.std{j};
            
            plot(mean(:,i), options.colors(j), lineWidth=2)
            fillRegion = [(mean(:,i) + std(:,i)); flipud(mean(:,i) - std(:,i))];
            fill([t, fliplr(t)]', fillRegion, options.colors(j), FaceAlpha=0.2, ...
                EdgeColor='none', HandleVisibility='off')
        end
        hold off
        title(data.labels(i), FontSize=10, interpreter='latex')
        axis(options.axisLimits)
        if mod(i,3) == 1
            ylabel("Magnitude")
        end
        if i>numel(data.labels)-numWindows
            xlabel("Time Points")
        end
        % if i == 1 && isfield(options, legend)
        %     legend(options.legend)
        % end
    end
end

