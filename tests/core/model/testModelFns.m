% preconditions
model = Model('arm26.osim');

%% Check applying frame parameter update (parent, translation)
newCoord = 10;
applyFrameParameterValue(model, newCoord, 'r_elbow', 1, 1, 1);
assert(getFrameParameterValue(model, 'r_elbow', 1, 1, 1)==newCoord);

%% Check applying frame parameter update (parent, orientation)
newCoord = 11;
applyFrameParameterValue(model, newCoord, 'r_elbow', 1, 0, 1);
assert(getFrameParameterValue(model, 'r_elbow', 1, 0, 1)==newCoord);

%% Check applying frame parameter update (child, translation)
newCoord = 12;
applyFrameParameterValue(model, newCoord, 'r_elbow', 0, 1, 1);
assert(getFrameParameterValue(model, 'r_elbow', 0, 1, 1)==newCoord);

%% Check applying frame parameter update (child, orientation)
newCoord = 13;
applyFrameParameterValue(model, newCoord, 'r_elbow', 0, 0, 1);
assert(getFrameParameterValue(model, 'r_elbow', 0, 0, 1)==newCoord);