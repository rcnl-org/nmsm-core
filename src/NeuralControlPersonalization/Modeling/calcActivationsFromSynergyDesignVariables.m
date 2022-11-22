function a = calcActivationsFromSynergyDesignVariables(x,params)
nSynergies = params.nSynergies;
nMuscles_leg = params.nMuscles_legs/2;
% Unpack design variables
[commands,weights] = unpackDesignVariables(x,params);

% Form feedforward muscle activations from synergies
a_right = commands(:,1:nSynergies/2)*weights(1:nSynergies/2,:);
a_left = commands(:,nSynergies/2+1:end)*weights(nSynergies/2+1:end,:);
a = [a_right(:,1:nMuscles_leg),a_left(:,1:nMuscles_leg),a_right(:,nMuscles_leg+1:end),a_left(:,nMuscles_leg+1:end)];