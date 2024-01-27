% This function sets the value of the coordinate in the given state from
% the data within the storage object.

% Copyright RCNL *change later*

% (Model, State, Storage, number, number) -> None
% Sets value of state coordinates from a Storage object row and column
function setValueFromStorage(model, state, storage, row, column, params)
import org.opensim.modeling.*
dbl = ArrayDouble();
storage.getDataColumn(column-1, dbl);
coord = getCoordinateFromName(model, storage.getColumnLabels.get(column));
value = dbl.get(row);
%         applyGaussian(value, params, 'rotationNoise')*3.14/180);

%     coord.setValue(state, applyGaussian(value,params, 'translationNoise'));
coord.setValue(state, value)
end

function output = applyGaussian(value, params, fieldName)
if(isfield(params, fieldName))
    if(isnumeric(params.(fieldName)))
        output = value + normrnd(0, params.(fieldName));
    else
        output = value;
    end
else
    output = value;
end
end