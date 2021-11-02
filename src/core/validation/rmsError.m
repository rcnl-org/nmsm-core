function output = rmsError(value, expected)
total = 0;
for i=1:length(expected)
    total = total + (expected(i)-value(i))^2;
end
output = sqrt(total/length(expected));
end

