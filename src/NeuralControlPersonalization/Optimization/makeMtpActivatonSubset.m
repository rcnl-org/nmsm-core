function [activationsWithMtpData, activationsWithoutMtpData] = makeMtpActivatonSubset(activations, ...
    mtpActivatonColumnNames, muscleTendonColumnNames)
index = ismember(mtpActivatonColumnNames, ...
    muscleTendonColumnNames);
activationsWithMtpData = activations(:, index, :);
activationsWithoutMtpData = activations(:, ~index, :);
end

