function runsimplehints(csvfile, lhs)

% Read data from csvfile and 
% compute correlation of all expressions with LHS
[corrArray, Data] = correlation(csvfile, lhs);
% We are interested only in the absolute values of the correlation.
absCorrArray = abs(corrArray(1,:));

temp = transpose(absCorrArray);
csvwrite('corrArray', temp);

% Sort in the descending order of correlation values.
[sortedCorrArray,sortIndex] = sort(absCorrArray(1,:),'descend');
% sortIndex is used to map the element back to its original position (which
% is the column number of the corresponding expression).
sortedCorrArray(2,:) = sortIndex;

% Compute set of expressions for simple hints
finalSetSimpleHints = simplehints(sortedCorrArray, absCorrArray, Data, lhs);

writefinalSet(finalSetSimpleHints, 'simplehints');

% Save the workspace for use when computing compound hints
save('tempfile');

% Write down the expressions with the highest correlation. We have to classify
% them into 3 sets based on edit distance.

writetopexpressions(sortedCorrArray, 'expressionsfile');

end
