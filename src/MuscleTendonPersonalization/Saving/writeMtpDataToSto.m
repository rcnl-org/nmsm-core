function writeMtpDataToSto(columnLabels, taskNames, data, directory, fileName)
if ~exist(directory, "dir")
    mkdir(directory);
end
for i = 1 : size(data,1)
    writeToSto(columnLabels, 1:1:length(data(i,:,:)), ...
        permute(data(i,:,:), [3 2 1]), strcat(directory, "\", taskNames(i), fileName))
end
end