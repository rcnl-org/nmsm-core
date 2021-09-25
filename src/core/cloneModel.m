% Clones a model to allow for modification of the new model without
% changing any values in the original model. This function is important to
% ensure functions that return a new model do not modify the original
% model. Keywords include: copy, deep copy, clone

% copyright RCNL *change later*

% (Model) -> (Model)
% Duplicate model as a new object separate from the original model
function outputModel = cloneModel(inputModel)
    import org.opensim.modeling.Model;
    outputModel = inputModel.clone();
end

