function textOrAlternate = parseElementTextByNameOrAlternate(tree, ...
        elementStringOrStringArray, alternate)
    try
elements = elementStringOrStringArray;
    if ischar(elementStringOrStringArray) || isstring(elementStringOrStringArray)
        elements = string([elementStringOrStringArray]);
    end
    for i = 1:length(elements)
      if ~strcmp(elements(i), elements(end))
        tree = getFieldByNameOrError(tree, elements(i));
      else
        textOrAlternate = getFieldByNameOrError(tree, elements(i)).Text;
      end
    catch
      textOrAlternate = alternate;
    end
end
