exprfile=$1
partitionfile=$2
rhsfile=$3
attrmap=$4
typefile=$5

tempexprfile="temp.expressions.file"
temprhsfile="temp.rhs.file"

rm -f $partitionfile $tempexprfile $temprhsfile

typestring=""
while read line
do
	typestring="$typestring $line"
done < $typefile

# The file 'expressionsfile' contains column numbers of the corresponding
# expressions. Find out the actual expressions from $attrmap given as input.
while read line
do
	text=$(sed -n "${line}{p;q;}" $attrmap)
	expr=$(sed "s/^ *$line *: *\(.*\)$/\1/" <<< $text)
	echo "$line" >> $tempexprfile
	echo "$typestring $expr;" >> $tempexprfile
done < $exprfile

while read line
do
	text=$(sed -n "${line}{p;q;}" $attrmap)
	expr=$(sed "s/^ *$line *: *\(.*\)$/\1/" <<< $text)
	echo "$typestring $expr;" >> $temprhsfile
done < $rhsfile

#java -jar partitionExpressions.jar $tempexprfile $temprhsfile $partitionfile
java minthint.algorithms.PartitionExpressions $tempexprfile $temprhsfile $partitionfile

rm -f $tempexprfile $temprhsfile
