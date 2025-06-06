function [tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles)
    import org.opensim.modeling.*
    tracked = struct();
    results = struct();

    trackedDataStorage = Storage(trackedDataFile);
    [tracked.labels, tracked.time, tracked.data] = parseMotToComponents(...
        org.opensim.modeling.Model(), trackedDataStorage);
    tracked.data = tracked.data';
    % We want time points to start at zero.
    if tracked.time(1) ~= 0
        tracked.time = tracked.time - tracked.time(1);
    end
    tracked.time = tracked.time / tracked.time(end);

    for j=1:numel(resultsDataFiles)
        resultsDataStorage = Storage(resultsDataFiles(j));
        [results.labels{j}, results.time{j}, results.data{j}] = parseMotToComponents(...
            org.opensim.modeling.Model(), resultsDataStorage);
        results.data{j} = results.data{j}';
        if results.time{j} ~= 0
            results.time{j} = results.time{j} - results.time{j}(1);
        end
        results.time{j} = results.time{j} / results.time{j}(end);
    end
end