function [tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles, model)
    import org.opensim.modeling.*
    if nargin < 3
        model = org.opensim.modeling.Model();
    end
    tracked = struct();
    results = struct();
    tracked.dataFile = trackedDataFile;
    results.dataFiles = resultsDataFiles;
    
    trackedDataStorage = Storage(trackedDataFile);
    [tracked.labels, tracked.time, tracked.data] = parseMotToComponents(...
        model, trackedDataStorage);
    tracked.data = tracked.data';
    % We want time points to start at zero.
    if tracked.time(1) ~= 0
        tracked.time = tracked.time - tracked.time(1);
    end
    tracked.normalizedTime = tracked.time / tracked.time(end);
    results.data = {};
    results.labels = {};
    results.time = {};
    for j=1:numel(resultsDataFiles)
        resultsDataStorage = Storage(resultsDataFiles(j));
        [results.labels{j}, results.time{j}, results.data{j}] = parseMotToComponents(...
            model, resultsDataStorage);
        results.data{j} = results.data{j}';
        if results.time{j} ~= 0
            results.time{j} = results.time{j} - results.time{j}(1);
        end
        results.normalizedTime{j} = results.time{j} / results.time{j}(end);
    end
end