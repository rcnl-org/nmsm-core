function text = parseElementTextByName(tree, elementStringOrStringArray)
elements = elementStringOrStringArray;
    if ischar(elementStringOrStringArray) || isstring(elementStringOrStringArray)
        elements = string([elementStringOrStringArray]);
    end
    for i = 1:length(elements)
      if ~strcmp(elements(i), elements(end))
        tree = getFieldByNameOrError(tree, elements(i));
      else
        text = getFieldByNameOrError(tree, elements(i)).Text;
      end
    end
end
