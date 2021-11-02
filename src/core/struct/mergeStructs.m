% This function merges two structures, if there is a duplicate name-value
% pair, the struct as the first argument will take precedent.

% Copyright RCNL *change later*

% (struct, struct) -> (struct)
% merge two structs with arg1 getting priority with name overlap
function output = mergeStructs(input1, input2)
if(~(isstruct(input1) && isstruct(input2)))
    throw(MException('','Both inputs are not structs'))
end
fields = fieldnames(input1);
output = input2;
for i=1:length(fields)
    output.(fields{i}) = input1.(fields{i});
end
end

