% This function takes a struct and a fieldname and returns either the value
% or an empty struct

% Copyright RCNL *change later*

% (struct, string) -> (Any)
% Returns the value of the field or an empty struct
function output = valueOrEmpty(inputStruct,fieldname)
if(isfield(inputStruct, fieldname))
    output = inputStruct.(fieldname);
else
    output = struct();
end
end

