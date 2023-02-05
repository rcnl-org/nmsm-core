%% Test rmsError

value = [5, 10];
expected = [6, 8];
expectedResult = sqrt(2.5);

assert(rmsError(value, expected) == expectedResult);