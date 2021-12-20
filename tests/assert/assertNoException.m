% This function asserts true when the function does not throw an exception,
% this can be used for the verify*something* functions such that a positive
% test will not throw an exception, thus making it passing.
%
% Example use: assertNoException(@()verifyChar('test'))
%
% (

function assertNoException(fn)
try
    fn();
catch
    assert(false);
    return
end
assert(true);
end

