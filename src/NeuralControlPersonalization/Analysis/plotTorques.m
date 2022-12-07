function plotTorques(activations, jointNames, inputs, params)
muscleJointMoments = zeros(inputs.numPoints, inputs.numJoints);
% net moment
for i = 1:inputs.numPoints
    for j = 1:inputs.numJoints
        muscleTendonForce = calcMuscleTendonForce(activations(i, j), ...
            inputs.muscleTendonLength(i, j), ...
            inputs.muscleTendonVelocity(i, j), j, inputs);
        for k = 1:inputs.numMuscles
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + inputs.momentArms(i, k, j) * muscleTendonForce;
        end
    end
end
figure;
for i = 1:inputs.numJoints
    subplot(4, 4, i)
    plot(inputs.NCPtimePercent, inputs.inverseDynamicsMoments(:, i), 'k-', ...
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
