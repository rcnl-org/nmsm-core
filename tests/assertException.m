% This function is used to test if a function call causes an exception. In
% the case where an exception is not causes, the assertion will be false.
%
% Example use: assertException(@()testFn(arg1, arg2))
%
% (fn with no arguments) -> (None)
function assertException(fn)
try
    fn();
catch
    assert(true);
    return
end
    assert(false);
end

