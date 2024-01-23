function momentArms = readMomentArmsForPlotting(precalInputs)
    momentArmDirectory = fullfile(precalInputs.passiveInputDirectory, "MAData");
    momentCoordinates = precalInputs.coordinateNames;
    momentArms = zeros(12, 6, 86, 101);
    momentArmFolders = dir(momentArmDirectory);
    momentArmFolders = momentArmFolders(3:end);
    coordinateNames = "MomentArm_"+precalInputs.coordinateNames+".sto";
    for i=1:numel(momentArmFolders)
        momentArmFiles = dir(fullfile(momentArmFolders(i).folder, momentArmFolders(i).name));
        momentArmFiles = momentArmFiles(3:end);
        k = 1;
        for j = 1:numel(momentArmFiles)
            if contains(momentArmFiles(j).name, coordinateNames)
                data = storageToDoubleMatrix(fullfile(momentArmFiles(j).folder, momentArmFiles(j).name));
                momentArms(i, k, :, :) = data;
                k = k + 1;
            end
        end
    end
    includedIndices = ismember( ...
            precalInputs.passiveMuscleTendonLengthColumnNames, precalInputs.muscleNames);
    momentArms = momentArms(:, :, includedIndices, :);
    temp = momentArms;
    momentArms(:,5,:,:) = temp(:, 1, :, :);
    momentArms(:,2,:,:) = temp(:, 2, :, :);
    momentArms(:,1,:,:) = temp(:, 3, :, :);
    momentArms(:,3,:,:) = temp(:, 4, :, :);
    momentArms(:,4,:,:) = temp(:, 5, :, :);
    momentArms(:,6,:,:) = temp(:, 6, :, :);
end

