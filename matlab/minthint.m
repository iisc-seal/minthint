function minthint(csvfile, lhscol, attrmap, rhsfile, typefile)

addpath(genpath('./matlab'));

runsimplehints(csvfile, lhscol);

command = 'bash shell-scripts/compute-partitions.sh expressionsfile partitionsfile';
command = [command ' ' rhsfile ' ' attrmap ' ' typefile];
system(command);

runcompoundhints('partitionsfile');

command = 'bash shell-scripts/synthhints.sh';
command = [command ' ' attrmap ' corrArray ' rhsfile ' ' typefile];
system(command);

end
