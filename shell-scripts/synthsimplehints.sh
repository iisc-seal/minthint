simplehintsexprsfile=$1
attrmap=$2
rhsexprsfile=$3
corrarrayfile=$4
typefile=$5
completerhsfile=$6

testfile="test.expr.file"
outfile="out.rhs.file"
tempfile="temp.file"
removefile="remove.file"

hintsfile="temp.simplehints.file"

rm -f $testfile $outfile $tempfile $hintsfile $removefile

typestring=""
while read line
do
	typestring="$typestring $line"
done < $typefile

while read line
do
	exprr=$(sed "s/^ *\([0-9]*\),.*$/\1/" <<< $line)
	corr=$(sed "s/^[^,]*,\([0-9.]*\) *$/\1/" <<< $line)

	text=$(sed -n "${exprr}{p;q;}" $attrmap)
	exprtext=$(sed "s/^ *$exprr *: *\(.*\)$/\1/" <<< $text)
	echo "$typestring $exprtext;" > $testfile
	java minthint.algorithms.ComputeMinEdit $testfile $rhsexprsfile $outfile

	output=`cat $outfile`
	edit=$(sed "s/^\([-0-9]*\):.*$/\1/" <<< $output)
	rhsexpr=$(sed "s/^[^:]*:\([-0-9]*\) *$/\1/" <<< $output)
	if [ $rhsexpr -gt 0 ]
	then
		text=$(sed -n "${rhsexpr}{p;q;}" $attrmap)
		rhsexprtext=$(sed "s/^ *$rhsexpr *: *\(.*\)$/\1/" <<< $text)

		rhsexprcorr=`sed -n "${rhsexpr}{p;q;}" $corrarrayfile`

		echo "$typestring $rhsexprtext;" >> $tempfile
	fi

	if [ $edit -eq -1 ]
	then
		continue
	fi

	if [ $edit == 0 ]
	then
		echo "Retain $exprtext, $corr" >> $hintsfile
	else
	if [ $edit == 1 ] || [ $edit == 2 ]
	then
		score1=`echo "1 - $rhsexprcorr" | bc`
		if [ $(echo " $score1 > $corr" | bc) -eq 1 ]
		then
			s=$score1
		else
			s=$corr
		fi
		echo "Replace $rhsexprtext with $exprtext, $s" >> $hintsfile
	else
		echo "Insert $exprtext, $corr" >> $hintsfile
	fi
	fi
done < $simplehintsexprsfile

java minthint.algorithms.ComputeRemovalNodes $completerhsfile $tempfile $removefile $rhsexprsfile

while read line
do
	text=$(sed -n "${line}{p;q;}" $attrmap)
	exprtext=$(sed "s/^ *$line *: *\(.*\)$/\1/" <<< $text)
	corr=`sed -n "${line}{p;q;}" $corrarrayfile`
	echo "Remove $exprtext, $corr" >> $hintsfile
done < $removefile

rm -f $testfile $outfile $removefile $tempfile
