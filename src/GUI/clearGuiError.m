function clearGuiError(fieldObject, iconObject)
    if ~isempty(fieldObject)
        fieldObject.BackgroundColor = get(groot,'defaultUicontrolBackgroundColor');
    end
    if ~isempty(iconObject)
        iconObject.Visible = 'off';
    end
end