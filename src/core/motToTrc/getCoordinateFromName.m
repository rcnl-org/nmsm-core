% This function returns a mutable coordinate for changing the position of a
% model. This coordinate can be used in coord.setValue(state, value)

% Copyright RCNL *change later*

% (Model, string) -> (Coordinate)
% Returns a coordinate with the given name
function coord = getCoordinateFromName(model, name)
    for i=0:model.getJointSet().getSize()-1
        joint = model.getJointSet.get(i);
        for j=0:joint.numCoordinates()-1
            if(joint.get_coordinates(j).getName() == name)
                coord = joint.upd_coordinates(j);
                return
            end
        end
    end
end