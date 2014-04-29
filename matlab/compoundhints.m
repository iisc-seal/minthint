function output = compoundhints(Data, corrArray, lhs, starting)

[row,col]=size(Data);
N = 5;
delta = 0.6;

z = zeros(row, N);
finalSet = zeros(5,2);

z(:,1) = Data(:, starting);
finalSet(1,1) = starting;
finalSet(1,2) = corrArray(1, starting);
countExprs = 1;

while true
    [partialArray, dummy] = partialcorr(Data(:,lhs), Data(:,:), z, 'type', 'spearman', 'rows', 'pairwise');
    partialArray(lhs) = 0;
    partialArray(isnan(partialArray)) = 0;
    
    absPartialArray = abs(partialArray(1,:));
    
    [sortedPartialArray,IX] = sort(absPartialArray(1,:), 'descend');
    sortedPartialArray(2,:) = IX;
    
    partialcorrVal = sortedPartialArray(1,1);
    if (partialcorrVal >= delta)
        highest = sortedPartialArray(2,1);
        countExprs = countExprs + 1;
        z(:,countExprs) = Data(:,highest);
        finalSet(countExprs,1) = highest;
        finalSet(countExprs,2) = corrArray(highest);
        if countExprs == N
            break
        end
    else
        break
    end
end

output = finalSet;
