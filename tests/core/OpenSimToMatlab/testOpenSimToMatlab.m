
stringArray = ["test1", "test2"];
numberArray = [5, 6];
arrayStr = org.opensim.modeling.ArrayStr();
arrayStr.append("test1");
arrayStr.append("test2");
vec3 = org.opensim.modeling.Vec3(5, 6, 7);

%% Check stringArrayToStdVectorString
assert(isa(stringArrayToStdVectorString(stringArray), ...
    "org.opensim.modeling.StdVectorString"));

%% Check stringArrayToArrayStr
assert(isa(stringArrayToArrayStr(stringArray), ...
    "org.opensim.modeling.ArrayStr"));

%% Check numberArrayToArrayDouble
assert(isa(numberArrayToArrayDouble(numberArray), ...
    "org.opensim.modeling.ArrayDouble"));

%% Check doubleArrayToRowVector
assert(isa(doubleArrayToRowVector(numberArray), ...
    "org.opensim.modeling.RowVector"));

%% Check arrayStrToStringArray
assert(all(arrayStrToStringArray(arrayStr) == ["test1", "test2"]))

%% Check Vec3ToArray
assert(all(Vec3ToArray(vec3) == [5, 6, 7]))