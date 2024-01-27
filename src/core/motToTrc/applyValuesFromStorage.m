% This function iterates through the storage and applies the coordinate
% values in order.

% Copyright RCNL *change later*

% (Model, State, Storage, TimeSeriesTableVec3, number) -> None
function applyValuesFromStorage(model, state, storage, table, params)
import org.opensim.modeling.*
for i=0:storage.getSize()-1
    for j=1:storage.getColumnLabels().size()-1
        setValueFromStorage(model, state, storage, i, j, params)
        model.assemble(state);
    end
    model.assemble(state);
    table.appendRow(i/params.dataRate, ...
    recordMarkersFromState(model, state));
end
end