function writetopexpressions(sortedCorrArray, filename)

delta = 0.6;
i = 1;

% Get the highest correlation value
firstcorrVal = sortedCorrArray(1,1);
if firstcorrVal <= delta
    return;
end

% File in which to write the top expressions
fID = fopen(filename, 'w');

% This loop writes all expressions that have the highest correlation value into
% the given file
while 1
    corrVal = sortedCorrArray(1, i);
    if corrVal ~= firstcorrVal
	break;
    end

    format = '%d\n';
    fprintf(fID, format, sortedCorrArray(2,i));

    i = i + 1;
end

fclose(fID);
end
