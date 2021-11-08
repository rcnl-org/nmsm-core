% This function returns the first instance of a field matching the given
% name and can be used to find a field in a struct that has been parsed
% from and XML (xml2struct)

% Copyright RCNL *change later*

% (struct, field) => (struct)
% Find first instance of field in nested struct
function output = getFieldByName(deepStruct, field)
output = false;
try
    output = deepStruct.(field);
    return
catch
end
if(isstruct(deepStruct))
    fields = fieldnames(deepStruct);
    for i=1:length(fields)
        output = getFieldByName(deepStruct.(fields{i}),field);
        if(isstruct(output))
            return
        end
    end
end
end

