function throwGuiError(errorMessage, fieldObject, iconObject)
    if ~isempty(fieldObject)
        fieldObject.BackgroundColor = [1.00,0.67,0.67];
    end
    if ~isempty(iconObject)
        iconObject.Visible = 'on';
        iconObject.Tooltip = errorMessage;
    end
end