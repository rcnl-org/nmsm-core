% Preconditions
model = Model('arm26.osim');

%% Test verifyChar

assertNoException(@()verifyChar('test'));
assertException(@()verifyChar(6));
assertException(@()verifyChar({}));

%% Test verifyJointModelPersonalizationFunctionArgs

assertNoException(@()verifyJointModelPersonalizationFunctionsArgs( ...
    model, {{'r_elbow', 1, 1, 0}}));
assertException(@()verifyJointModelPersonalizationFunctionArgs(model, ...
    'hello'));

%% Test verifyMarkersReferenceArg

assertNoException(@()verifyMarkersReferenceArg('walk_free_01.trc'));
assertException(@()verifyMarkersReferenceArg('walk_free_02.trc'));
assertException(@()verifyMarkersReferenceArg(7));

%% Test verifyModelArg

assertNoException(@()verifyModelArg(model))
assertNoException(@()verifyModelArg('arm26.osim'))
assertException(@()verifyModelArg(6));

%% Test verifyNumeric

assertNoException(@()verifyNumeric(5));
assertNoException(@()verifyNumeric(-0.00123));
assertException(@()verifyNumeric('Hello'));

%% Test verifyTrue

assertNoException(@()verifyTrue(true));
assertException(@()verifyTrue(false));
assertNoException(@()verifyTrue(5 == 5));

%% Test verifyParam

testStruct.testField = "test";
assertNoException(@()verifyParam(testStruct, "testField", @verifyChar, 'test'))
assertException(@()verifyParam(testStruct, "testField", @verifyNumeric, ...
    'test'))
assertException(@()verifyParam(testStruct, "notTestField", ...
    @verifyChar, 'test'))

%% Test verifyLength

assertNoException(@()verifyLength([1, 2, 3], 3));
assertException(@()verifyLength([1, 2, 3], 2));

%% Test verifyField

testStruct.testField = "test";
assertNoException(@()verifyField(testStruct, "testField"));
assertException(@()verifyField(testStruct, "notTestField"));

%% Test verifyMuscleTendonPersonalizationData

inputs.jointMoment = [];
inputs.muscleTendonLength = zeros(2, 3, 3);
inputs.muscleTendonVelocity = zeros(2, 3, 3);
inputs.muscleTendonMomentArm = [];
inputs.emgData = [];

verifyMuscleTendonPersonalizationData(inputs);
