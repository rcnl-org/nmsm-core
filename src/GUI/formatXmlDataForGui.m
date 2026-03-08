function tree = formatXmlDataForGui(tree)
    if ischar(tree) 
        tree = convertCharsToStrings(strsplit( ...
            tree, " "));
        if ~isnan(str2double(tree))
            tree = str2double(tree);
        end
        return
    end
    
    if isstruct(tree) 
        structFields = fields(tree);
        if length(structFields) == 1 && strcmp(structFields, "Text")
                tree = formatXmlDataForGui(tree.(structFields{1}));
        else
            for i = 1 : numel(structFields)
                if strcmp(structFields{i}, "Attributes")
                    return
                end
                tree.(structFields{i}) = formatXmlDataForGui(tree.(structFields{i}));
            end
        end
    end

    if iscell(tree)
        for i = 1 : length(tree)
            tree{i} = formatXmlDataForGui(tree{i});
        end
    end
end