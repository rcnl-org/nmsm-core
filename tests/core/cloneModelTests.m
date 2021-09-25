% preconditions
import org.opensim.modeling.*
model1 = Model("Rajagopal_v1.osim");

%% Test if models are separate
model2 = cloneModel(model1);
pelvis = model2.get_BodySet().get(1);
model2.get_BodySet().remove(1);
assert(model1.get_BodySet().getSize() == 22)
assert(model2.get_BodySet().getSize() == 21)