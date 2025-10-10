function [activationsWithMtpData, activationsWithoutMtpData] = ...
    makeCasadiMtpActivatonSubset(activations, ...
    mtpActivationsColumnNames, muscleTendonColumnNames, numTrials)
index = ismember(muscleTendonColumnNames, mtpActivationsColumnNames);
index = repmat(index, 1, numTrials);
trueIndex = find(index);
falseIndex = find(~index);
activationsWithMtpData = activations(trueIndex, :);
activationsWithoutMtpData = activations(falseIndex, :);
end

