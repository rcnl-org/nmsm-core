% This function throws an error if the input value is not an argument to
% instantiate a model object. It essentially tests if a model can be made
% in a secure environment and allows for catching the error and handling it
% appropriately.
% 
% This function can be used as a simple line in a function or contained
% within a try-catch to allow for a custom message/response.

% Copyright RCNL *change later*

% (Any) -> (None)
% Throws an exception if the input cannot make a model.
function verifyModelArg(input)
import org.opensim.modeling.*
try
    Model(input);
catch
    throw(MException('', 'input is not a model'));
end
end