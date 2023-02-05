
filename = "test.sto";
columnNames = ["column1", "column2"];
time = [1, 2, 3];
data = [4, 5, 6; 7, 8, 9];

%% Check writeToSto
writeToSto(columnNames, time, data', filename);
assert(isfile(filename));
