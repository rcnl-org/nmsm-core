function struct = formatGuiDataForXml(struct)
    if isstring(struct)
        struct = convertStringsToChars(strjoin( ...
            struct, " "));
        return
    end
    
    if isstruct(struct)
        structFields = fields(struct);
        for i = 1 : numel(structFields)
            struct.(structFields{i}) = formatGuiDataForXml(struct.(structFields{i}));
        end
    end

    if iscell(struct)
        for i = 1 : length(struct)
            struct{i} = formatGuiDataForXml(struct{i});
        end
    end
end