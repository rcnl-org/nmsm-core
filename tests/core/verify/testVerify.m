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

