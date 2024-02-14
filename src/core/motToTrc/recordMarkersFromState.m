% This function returns a RowVectorOfVec3 from a given state including all
% markers in the state.

% Copyright RCNL *change later*

% (Model, State) -> (RowVectorOfVec3)
% Return a RowVectorOfVec3 of marker positions for a given state
function row = recordMarkersFromState(model, state)
import org.opensim.modeling.*
row = RowVectorVec3(model.getMarkerSet().getSize());
for i=0:model.getMarkerSet().getSize()-1
    m = model.getMarkerSet().get(i);
    row.set(i,m.getLocationInGround(state));
end
end