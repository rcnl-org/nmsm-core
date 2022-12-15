import org.opensim.modeling.Storage

grfFile = "grf.mot";
model = Model("optModel_v6_correct_height.osim");
labFloorHeight = 0;
storage = Storage(grfFile);
[grfColumnNames, time, grfData] = parseMotToComponents(model, ...
    Storage(grfFile));

force1X = grfData(1, :);
force1Y = grfData(2, :);
force1Z = grfData(3, :);
moment1X = grfData(4, :);
moment1Y = grfData(5, :);
moment1Z = grfData(6, :);
force2X = grfData(7, :);
force2Y = grfData(8, :);
force2Z = grfData(9, :);
moment2X = grfData(10, :);
moment2Y = grfData(11, :);
moment2Z = grfData(12, :);
electricalCenter1X = grfData(13, :);
electricalCenter1Y = grfData(14, :);
electricalCenter1Z = grfData(15, :);
electricalCenter2X = grfData(16, :);
electricalCenter2Y = grfData(17, :);
electricalCenter2Z = grfData(18, :);

centerOfPressure1Y = ones(1, length(electricalCenter1Y)) * labFloorHeight;
centerOfPressure2Y = ones(1, length(electricalCenter2Y)) * labFloorHeight;

% Solve for center of pressure
centerOfPressure1X = electricalCenter1X + (moment1Z - force1X .* ...
    (electricalCenter1Y - labFloorHeight)) ./ force1Y;
centerOfPressure2X = electricalCenter2X + (moment2Z - force2X .* ...
    (electricalCenter2Y - labFloorHeight)) ./ force2Y;
centerOfPressure1Z = electricalCenter1Z - (moment1X + force1Z .* ...
    (electricalCenter1Y - labFloorHeight)) ./ force1Y;
centerOfPressure2Z = electricalCenter2Z - (moment2X + force2Z .* ...
    (electricalCenter2Y - labFloorHeight)) ./ force2Y;

% Solve for free moment
freeMoment1 = moment1Y + force1X .* (electricalCenter1Z - ...
    centerOfPressure1Z) - force1Z .* (electricalCenter1X - ...
    centerOfPressure1X);
freeMoment2 = moment2Y + force2X .* (electricalCenter2Z - ...
    centerOfPressure2Z) - force2Z .* (electricalCenter2X - ...
    centerOfPressure2X);

% Export results
grfColumnNames(13) = "COP1X";
grfColumnNames(14) = "COP1Y";
grfColumnNames(15) = "COP1Z";
grfColumnNames(16) = "COP2X";
grfColumnNames(17) = "COP2Y";
grfColumnNames(18) = "COP2Z";
grfData(4, :) = zeros(size(grfData(4, :)));
grfData(6, :) = zeros(size(grfData(6, :)));
grfData(10, :) = zeros(size(grfData(10, :)));
grfData(12, :) = zeros(size(grfData(12, :)));
grfData(5, :) = freeMoment1;
grfData(11, :) = freeMoment2;
grfData(13, :) = centerOfPressure1X;
grfData(14, :) = centerOfPressure1Y;
grfData(15, :) = centerOfPressure1Z;
grfData(16, :) = centerOfPressure2X;
grfData(17, :) = centerOfPressure2Y;
grfData(18, :) = centerOfPressure2Z;
writeToSto(grfColumnNames, time, grfData', "cop_converted_" + grfFile);
