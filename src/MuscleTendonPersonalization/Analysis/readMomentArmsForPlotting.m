function momentArms = readMomentArmsForPlotting(precalInputs)
    momentArmDirectory = fullfile(precalInputs.passiveInputDirectory, "MAData");
    momentCoordinates = precalInputs.coordinateNames;
    momentArmFolders = dir(momentArmDirectory);
end

