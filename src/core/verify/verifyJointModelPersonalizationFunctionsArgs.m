% This function throws an error if the input value is not an argument to
% instantiate a cell array of functions for Joint Model Personalization.
% It essentially tests if a cell array of functions can be made
% in a secure environment and allows for catching the error and handling it
% appropriately.
% 
% This function can be used as a simple line in a function or contained
% within a try-catch to allow for a custom message/response.

% Copyright RCNL *change later*

% (Any) -> (None)
% Throws an exception if the input cannot make a cell array of functions.
function verifyJointModelPersonalizationFunctionsArgs(model, input)
import org.opensim.modeling.*
model = Model(model); %don't modify original model, or instantiate filename
for i=1:length(input)
    try model.getJointSet().get(input{i}{1});
    catch;MException('', strcat("joint name doesn't exist for entry ", i));
    end
    try
        logical(input{i}{2});
        logical(input{i}{3});
        paramNum = input{i}{4};
        if(~(paramNum >= 0 && paramNum <=2)); throw(MException()); end
    catch
        throw(MException('', 'invalid function input parameters'))
    end
end
end

