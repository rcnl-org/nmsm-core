% Preconditions
struct1 = struct('Test1','Arg1', 'Test2','Arg2');
struct2 = struct('Test1','Arg3', 'Test3', 'Arg4');

%% Test mergeStructs
output = mergeStructs(struct1, struct2);

assert(strcmp(output.Test1, 'Arg1'));
assert(length(fieldnames(output)) == 3);
assertException(@()mergeStructs(struct1, ''));

%% Test valueOrAlternate

assert(strcmp(valueOrAlternate(struct1, 'Test1', 'Hello'), 'Arg1'));
assert(strcmp(valueOrAlternate(struct1, 'Test3', 'Hello'), 'Hello'));

%% Test valueOrEmptyString

assert(strcmp(valueOrEmptyString(struct1, 'Test1'), 'Arg1'));
assert(strcmp(valueOrEmptyString(struct1, 'Test3'), ''));

%% Test valueOrEmptyStruct

output = valueOrEmptyStruct(struct1, 'Test3');

assert(strcmp(valueOrEmptyStruct(struct1, 'Test1'), 'Arg1'));
assert(isstruct(output));
assert(isempty(fieldnames(output)));

%% Test valueOrZero

assert(strcmp(valueOrZero(struct1, 'Test1'), 'Arg1'));
assert(valueOrZero(struct1, 'Test3') == 0);