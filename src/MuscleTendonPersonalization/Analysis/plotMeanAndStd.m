function plotMeanAndStd(mean, std, time, color)
    plot(time, mean, color, linewidth=2)
    FillRegion = [(mean+std);
        flipud(mean-std)];
    fill([time, fliplr(time)]', FillRegion, color, FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
end