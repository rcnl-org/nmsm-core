function titleStrings = makeSubplotTitles(tracked, results)
for i = 1 : numel(tracked.labels)
    titleStrings{i} = [sprintf("%s", strrep(tracked.labels(i), "_", " "))];
    for j = 1 : numel(results.data)
        rmse = rms(tracked.resampledData{j}(:, i) - results.data{j}(:, i));
        titleStrings{i}(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
    end
end

