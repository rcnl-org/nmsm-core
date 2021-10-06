% This function returns either the value of the field given or the
% alternative value provided as a third argument.

% Copyright RCNL *change later*

% (struct, string, Any) -> (Any)

function output = valueOrAlternate(inputStruct, fieldName, alternative)
if(isfield(inputStruct, fieldName))
    output = inputStruct.(fieldName);
else
    output = alternative;
end
end

