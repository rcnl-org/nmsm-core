% This function takes a struct and a fieldname and returns either the value
% or the number zero

% Copyright RCNL *change later*

% (struct, string) -> (Any)
% Returns the value of the field or the number zero
function output = valueOrZero(inputStruct,fieldName)
if(isfield(inputStruct, fieldName))
    output = inputStruct.(fieldName);
else
    output = 0;
end
end

