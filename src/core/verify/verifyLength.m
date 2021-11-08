% This function returns true if the length of the object is the same as the
% second argument. This function is intended to be an easy way to verify
% the length of an object to ensure it is filled out correctly.

% Copyright RCNL *change later*

% (Any, integer) -> (None)
% Throws exception if length of the object doesn't match second argument
function verifyLength(obj,leng)
if(~length(obj)==leng)
    throw MException(obj + "is not of expected length")
end
end

