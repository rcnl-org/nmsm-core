function tracked = resampleTrackedData(tracked, results)
    trackedDataSpline = makeGcvSplineSet(tracked.time, ...
        tracked.data, tracked.labels);
    for j = 1 : numel(results.data)
        tracked.resampledData{j} = evaluateGcvSplines(trackedDataSpline, ...
            tracked.labels, results.time{j});
    end
end