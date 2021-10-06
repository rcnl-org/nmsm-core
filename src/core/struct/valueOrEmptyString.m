% This function returns either the value from a struct and given field name
% or an empty string ("")

% Copyright RCNL *change later*

% (struct, string) -> (Any)
% Returns the value for the given field or an empty string
function output = valueOrEmptyString(inputStruct,fieldName)
if(isfield(inputStruct, fieldName))
    output = inputStruct.(fieldName);
else
    output = "";
end
end