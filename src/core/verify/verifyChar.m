% This function throws an error if the input value is not a char.
% 
% This function can be used as a simple line in a function or contained
% within a try-catch to allow for a custom message/response.
% 
% (Any) -> (None)
% Throws an exception if the input cannot make a cell array of functions.

% Copyright RCNL *change later*


function verifyChar(input)
if(~ischar(input))
    throw(MException('','input is not a string'))
end
end

