% This function retreived getFieldByName's result, but if the result is
% that the element doesn't exist, it returns an error. This can be used to
% find the field name of required elements and throw a standard error when
% they are not available.

% Copyright RCNL *change later*

% (struct, string) -> (struct)
% Gets field by name or throws error
function output = getFieldByNameOrError(deepStruct, field)
output = getFieldByName(deepStruct, field);
if(~output)
    throw MException(strcat(field, " is not in the struct"))
end
end

