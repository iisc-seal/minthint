function [output_corrArray, data] = correlation(filename, lhs)

% import data into matrix A
Data=csvread(filename);

% compute correlation of all columns(i.e. expressions) with the LHS
% variable.
[corr_array, dummy] = corr(Data(:,lhs), Data(:,:), 'type', 'spearman', 'rows', 'pairwise');
% the LHS variable will obviously have high correlation with itself. Make
% it zero to prevent interference with later calculations.
corr_array(lhs) = 0;
% Replace all NaN values with 0. We sort this array later to find the
% highest correlated expression. We are not interested in NaN values.
corr_array(isnan(corr_array)) = 0;

output_corrArray = corr_array;
data = Data;