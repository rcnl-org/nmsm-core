%% preordered
tasks = {struct("index", struct("Text", "1"), "name", "one"), ...
    struct("index", struct("Text", "2"), "name", "two"), ...
    struct("index", struct("Text", "3"), "name", "three")};
correctNames = ["one", "two", "three"];

orderedTasks = orderByIndex(tasks);
for i = 1:length(orderedTasks)
    assert(orderedTasks{i}.name == correctNames(i));
end

%% out of order
tasks = {struct("index", struct("Text", "2"), "name", "two"), ...
    struct("index", struct("Text", "1"), "name", "one"), ...
    struct("index", struct("Text", "3"), "name", "three")};
correctNames = ["one", "two", "three"];

orderedTasks = orderByIndex(tasks);
for i = 1:length(orderedTasks)
    orderedTasks{i}.name
    assert(orderedTasks{i}.name == correctNames(i));
end

%% one element
tasks = { struct("index", struct("Text", "2"), "name", "two") };

orderedTasks = orderByIndex(tasks);
assert(orderedTasks{1}.name == 'two');

%% an element doesn't have an index
tasks = {struct("index", struct("Text", "2"), "name", "two"), ...
    struct("name", "one"), ...
    struct("index", struct("Text", "3"), "name", "three")};

assertException(@()orderByIndex(tasks));
