function runcompoundhints(partitionsfile)

% Load the workspace that we saved before (while computing simple hints)
load('tempfile.mat');

% We compute compound hints for each partition. Read the starting
% expression in each partition from the given file. Note: the column number
% of the starting expression is saved in the file and each partition is
% written into a different line
fID = fopen(partitionsfile, 'r');
tline = fgetl(fID);
id = 1;
while ischar(tline)
    [x, status] = str2num(tline);
    if status == 1
        if x ~= -1
            setCompoundHints = compoundhints(Data, corrArray, lhs, x);
            filename = ['compoundhints' int2str(id)];
            writefinalSet(setCompoundHints, filename);
        end
        id = id + 1;
    end
    tline = fgetl(fID);
end


end
