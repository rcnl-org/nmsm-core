function groundReactions = calcGroundReactions(springPositions, springVelocities, ...
    params, bodyLocations)

nframes = size(springPositions,1);

Rhsprings = 1:params.numSpringsRightHeel;
Rtsprings = params.numSpringsRightHeel+1:params.numSpringsRightHeel+params.numSpringsRightToe;
Lhsprings = params.numSpringsRightHeel+params.numSpringsRightToe+1:params.numSpringsRightHeel+params.numSpringsRightToe+params.numSpringsLeftHeel;
Ltsprings = params.numSpringsRightHeel+params.numSpringsRightToe+params.numSpringsLeftHeel+1:params.numSpringsRightHeel+params.numSpringsRightToe+params.numSpringsLeftHeel+params.numSpringsLeftToe;


% set spring positions for calculating moments about electrical centers
xposvals = springPositions(:,1:3:end);
yposvals = springPositions(:,2:3:end);
zposvals = springPositions(:,3:3:end);

% set vertical position of springs (modified later by code)
% yPens = -SpringPos(:,2:3:end);

% set spring velocities
xvel = springVelocities(:,1:3:end)+params.beltSpeed;
normvel = -springVelocities(:,2:3:end);
zvel = springVelocities(:,3:3:end);

% determine slip velocity of springs
slipvel = (xvel.^2+zvel.^2).^(1/2);

% determine normalized velocities of springs
slipOffset = 1e-4;
xvel = xvel./(slipvel+slipOffset);
zvel = zvel./(slipvel+slipOffset);

% % Continuous function that models in/out of contact condition
% c = 1000;
% yPens = yPens+log(exp(-c*yPens)+1)/c;
% yPens(isinf(yPens)) = 0;

klow = 1e-1;
h = 1e-3;
c = 5e-4;
ymax = 1e-2;

v = ones(nframes,1)*((params.springStiffness+klow)./(params.springStiffness-klow));
s = ones(nframes,1)*((params.springStiffness-klow)/2);
constant = -s.*(v.*ymax-c*log(cosh((ymax+h)/c)));
        
Fsprings = -s.*(v.*yposvals-c*log(cosh((yposvals+h)/c)))-constant;

Fsprings(isnan(Fsprings)) = min(min(Fsprings));
Fsprings(isinf(Fsprings)) = min(min(Fsprings));

% Add in slight slope for non-contact time frames in order to (maybe) help optimizer
% yPens = yPens+.00001*(yposvals);

% Calculate vGRF (Normal Force)
% Fy = (ones(nframes,1)*Kval).*yPens.*(1+(ones(nframes,1)*Cval).*(normvel));
Fy = Fsprings.*(1+(ones(nframes,1)*params.springDamping).*(normvel));
RFyHF = sum(Fy(:,Rhsprings),2);
RFyT = sum(Fy(:,Rtsprings),2);
LFyHF = sum(Fy(:,Lhsprings),2);
LFyT = sum(Fy(:,Ltsprings),2);

% New friction model
%dynamic friction
mu = params.dynamicFriction*tanh(slipvel/params.latchingVelocity); 

%static friction
% b = mu_s-mu_d;
% c = latchvel;
% d = latchvel;
% spos = b*exp(-((slipvel-c).^2)/(2*d^2));
% sneg = -b*exp(-((slipvel+c).^2)/(2*d^2));
% mu = mu+spos+sneg;

% damping friction
damping = params.viscousFriction*slipvel/params.latchingVelocity;
mu = mu+damping;

% Calculate horizontal forces
Fvals_individual = Fy.*mu;
% Resolve into components and sum forces for all springs
Fxvals_individual = -Fvals_individual.*xvel;
Fzvals_individual = -Fvals_individual.*zvel;

RFxHF = sum(Fxvals_individual(:,Rhsprings),2);
RFxT = sum(Fxvals_individual(:,Rtsprings),2);
RFzHF = sum(Fzvals_individual(:,Rhsprings),2);
RFzT = sum(Fzvals_individual(:,Rtsprings),2);
LFxHF = sum(Fxvals_individual(:,Lhsprings),2);
LFxT = sum(Fxvals_individual(:,Ltsprings),2);
LFzHF = sum(Fzvals_individual(:,Lhsprings),2);
LFzT = sum(Fzvals_individual(:,Ltsprings),2);

ECR = permute(bodyLocations.rightMidfootSuperior, [1 3 2]);
ECL = permute(bodyLocations.leftMidfootSuperior, [1 3 2]);

ECR = repmat(ECR,[1,sum([params.numSpringsRightHeel params.numSpringsRightToe]),1]);
ECL = repmat(ECL,[1,sum([params.numSpringsLeftHeel params.numSpringsLeftToe]),1]);

% Using the position vectors, calculate the moment contributions from each
% element about the electrical center
positionvec = cat(3, xposvals, yposvals, zposvals);
forcevec = cat(3, Fxvals_individual, Fy, Fzvals_individual); 
Moments = cross(positionvec-[ECR ECL],forcevec, 3);
xMoments = Moments(:,:,1);
yMoments = Moments(:,:,2);
zMoments = Moments(:,:,3);

% Sum the moments for all springs
RMxHF = sum(xMoments(:,Rhsprings),2);
RMxT = sum(xMoments(:,Rtsprings),2);
RMyHF = sum(yMoments(:,Rhsprings),2);
RMyT = sum(yMoments(:,Rtsprings),2);
RMzHF = sum(zMoments(:,Rhsprings),2);
RMzT = sum(zMoments(:,Rtsprings),2);

LMxHF = sum(xMoments(:,Lhsprings),2);
LMxT = sum(xMoments(:,Ltsprings),2);
LMyHF = sum(yMoments(:,Lhsprings),2);
LMyT = sum(yMoments(:,Ltsprings),2);
LMzHF = sum(zMoments(:,Lhsprings),2);
LMzT = sum(zMoments(:,Ltsprings),2);

% Set output
groundReactions.rightHeelForce = [RFxHF RFyHF RFzHF];
groundReactions.rightHeelMoment = [RMxHF RMyHF RMzHF];
groundReactions.leftHeelForce = [LFxHF LFyHF LFzHF];
groundReactions.leftHeelMoment = [LMxHF LMyHF LMzHF];
groundReactions.rightToeForce = [RFxT RFyT RFzT];
groundReactions.rightToeMoment = [RMxT RMyT RMzT];
groundReactions.leftToeForce = [LFxT LFyT LFzT];
groundReactions.leftToeMoment = [LMxT LMyT LMzT];
end