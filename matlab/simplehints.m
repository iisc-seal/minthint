function simplehintsOutput = simplehints(sortedCorrArray, corrArray, Data, lhs)

[rowsData, colsData] = size(Data);
% Assuming the upper bound on the number of expressions that we select in
% this procedure is N
N = 50;
% Threshold values for correlation and partial correlation
delta = 0.4;
beta = 0.1;

% finalSet stores the selected expressions
finalSet = zeros(N,2);
% controlSet stores the data of the selected expressions. This is used in
% computing partial correlation.
controlSet = zeros(rowsData, N);
% j counts the number of expressions selected
j = 1;

% Iterate through each expression according to sortedCorrArray. Note the number of
% columns in Data and sortedCorrArray are same.
for i = 1:colsData
    % First row of sortedCorrArray stores the correlation value.
    corrVal = sortedCorrArray(1, i);
    % Check for threshold value
    if (corrVal <= delta)
        break
    end
    % Second row of sortedCorrArray stores the column number of the
    % corresponding expression.
    currCol = sortedCorrArray(2, i);

    % compute partial correlation of LHS with expression at currCol with
    % the controlSet. controlSet is populated only till j columns.
    p = partialcorr(Data(:,lhs), Data(:,currCol), controlSet(:,1:j), 'type', 'spearman', 'rows', 'complete');

    % Check for threshold value
    if abs(p) >= beta
        % Add the corresponding expression to controlSet.
        % We allocated only N columns to controlSet. If j is above N, we
        % need to add an extra column to controlSet.
        if j <= N 
            controlSet(:, j) = Data(:, currCol);
        else
            controlSet = horzcat(controlSet, Data(:,currCol));
        end
        
        % Add the corresponding expression and likelihood to finalSet.
        finalSet(j, 1) = currCol;
        finalSet(j, 2) = corrArray(currCol);
        j = j + 1;
    end
end

simplehintsOutput = finalSet;
