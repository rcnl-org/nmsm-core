function plotTorques(activations, jointNames, inputs, params)
muscleJointMoments = zeros(inputs.numPoints, inputs.numJoints);
% net moment
for i = 1:inputs.numPoints
    for j = 1:inputs.numJoints
        for k = 1:inputs.numMuscles
            FMT = calcMuscleTendonForce(activations(i, k), ...
                inputs.muscleTendonLength(i, k), ...
                inputs.muscleTendonVelocity(i, k), k, inputs);
            r = inputs.rVals(i, k, j);
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + r * FMT;
        end
    end
end
figure;
for i = 1:inputs.numJoints
    subplot(4, 4, i)
    plot(inputs.NCPtimePercent, inputs.IDmomentVals(:, i), 'k-', ...
        inputs.NCPtimePercent, muscleJointMoments(:, i));
    hold all
    if rem(i, 4) == 1
        ylabel('Joint Torque (Nm)');
    end
    title(jointNames{i})
    if i == 4
        legend('ID', 'NCP');
    end
end
end
