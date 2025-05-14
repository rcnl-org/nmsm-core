function forces = calcGroundReactionByMarker(modelFileName, osimxFileName, ...
    ikFileName)
import org.opensim.modeling.*
model = Model(modelFileName);
ikStorage = Storage(ikFileName);

[ikColumnNames, ikTime, ikAngles] = parseMotToComponents(model, ikStorage);

ikAngles = ikAngles';
ikSpline = makeGcvSplineSet(ikTime, ikAngles, ikColumnNames);
ikVelocities = evaluateGcvSplines(ikSpline, ikColumnNames, ikTime, 1);

osimx = parseOsimxFile(osimxFileName, model);

toesBodyNames = ["toes_r", "toes_l"];
for i = 1 : numel(osimx.groundContact.contactSurface)
    contactSurface = osimx.groundContact.contactSurface{i};
    osimx.groundContact.contactSurface{i}.parentBody = ...
        convertCharsToStrings(contactSurface.hindfootBodyName);
    osimx.groundContact.contactSurface{i}.childBody = toesBodyNames(i);
    osimx.groundContact.contactSurface{i}.parentSpringPointsOnBody = [];
    for i = 1 : numel(osimx.groundContact.contactSurface{i}.springs)
        osimx.groundContact.contactSurface{i}.parentSpringPointsOnBody = ...
            [osimx.groundContact.contactSurface{i}.parentSpringPointsOnBody;
            osimx.groundContact.contactSurface{i}.springs]
    end

    
end

getSpringLocations(model, ikTime, ikAngles, ikVelocities, ...
        ikColumnNames, contactSurfaces)

end

function [springPositions, springVelocities] = getSpringLocations(model, ...
    time, positions, velocities, coordinateNames, contactSurfaces)

for i = 1:length(contactSurfaces)
    [springPositions.parent{i}, springVelocities.parent{i}] = ...
        pointKinematicsMatlabParallel(time, positions, velocities, ...
        contactSurfaces{i}.parentSpringPointsOnBody, ...
        contactSurfaces{i}.parentBody * ones(1, ...
        size(contactSurfaces{i}.parentSpringPointsOnBody, 1)), ...
        model, coordinateName);
    [springPositions.child{i}, springVelocities.child{i}] = ...
        pointKinematicsMatlabParallel(time, positions, velocities, ...
        contactSurfaces{i}.childSpringPointsOnBody, ...
        contactSurfaces{i}.childBody * ones(1, ...
        size(contactSurfaces{i}.childSpringPointsOnBody, 1)), ...
        model, coordinateNames);
end
end

