function [activationsWithMtpData, activationsWithoutMtpData] = makeMtpActivatonSubset(activations, ...
    mtpActivatonColumnNames, muscleTendonColumnNames)
index = ismember(muscleTendonColumnNames, mtpActivatonColumnNames);
activationsWithMtpData = activations(:, index, :);
activationsWithoutMtpData = activations(:, ~index, :);
end

