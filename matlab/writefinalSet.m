function writefinalSet(finalSet, filename)

% Find the number of non-zero rows in finalSet
count = size(find(finalSet(:,1) ~= 0), 1);

% Write the finalSet array as a csv file
csvwrite(filename, finalSet(1:count, :));
end