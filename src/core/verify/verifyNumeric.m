% This function throws an error if the input value is not a number.
% 
% This function can be used as a simple line in a function or contained
% within a try-catch to allow for a custom message/response.

% Copyright RCNL *change later*

% (Any) -> (None)
% Throws an exception if the input cannot make a cell array of functions.

function verifyNumeric(input)
if(~isnumeric(input))
    throw(MException('','input is not numeric'))
end
end

