function throwGuiError(errorMessage, fieldObject, iconObject)
        fieldObject.BackgroundColor = [1.00,0.67,0.67];
        iconObject.Visible = 'on';
        iconObject.Tooltip = errorMessage;
end