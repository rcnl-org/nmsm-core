% This function takes a struct and a fieldname and returns either the value
% or an empty struct

% Copyright RCNL *change later*

% (struct, string) -> (Any)
% Returns the value of the field or an empty struct
function output = valueOrEmptyStruct(inputStruct,fieldName)
if(isfield(inputStruct, fieldName))
    output = inputStruct.(fieldName);
else
    output = struct();
end
end

