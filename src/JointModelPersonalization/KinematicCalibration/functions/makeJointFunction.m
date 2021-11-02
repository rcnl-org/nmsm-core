% This function returns the joint function representing the function
% parameters for use as a function to be passed in the Joint Model
% Personalization and Kinematic Calibration modules.
% 
% (string, boolean, boolean, integer) -> (function)
% Returns the appropriate function for given input parameters

% Copyright RCNL *change later*

function fn = makeJointFunction(jointName, isParent, isTranslation, ...
    coordinateNumber)
if(isParent && isTranslation)
    fn = @(value, model) adjustParentTranslation(model, jointName, ...
        coordinateNumber, value);
end
if(isParent && ~isTranslation)
    fn = @(value, model) adjustParentOrientation(model, jointName, ...
        coordinateNumber, value);
end
if(~isParent && isTranslation)
    fn = @(value, model) adjustChildTranslation(model, jointName, ...
        coordinateNumber, value);
end
if(~isParent && ~isTranslation)
    fn = @(value, model) adjustChildOrientation(model, jointName, ...
        coordinateNumber, value);
end
end

