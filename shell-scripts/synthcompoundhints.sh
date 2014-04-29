compoundhintsexprsfile=$1
attrmap=$2
rhsexprsfile=$3
corrarrayfile=$4
typefile=$5
completerhsfile=$6

testfile="test.expr.file"
outfile="out.rhs.file"
tempfile="temp.file"
hintsfile="temp.hints.file"
removefile="remove.file"
comphintsfile="temp.comphints.file"

rm -f $testfile $outfile $tempfile $hintsfile $removefile $comphintsfile

typestring=""
while read line
do
	typestring="$typestring $line"
done < $typefile

maxcorr=0

while read line
do
	expr=$(sed "s/^ *\([0-9]*\),.*$/\1/" <<< $line)
	corr=$(sed "s/^[^,]*,\([0-9.]*\) *$/\1/" <<< $line)

	text=$(sed -n "${expr}{p;q;}" $attrmap)
	exprtext=$(sed "s/^ *$expr *: *\(.*\)$/\1/" <<< $text)
	echo "$typestring $exprtext;" > $testfile
	#cat $testfile
	#cat $rhsexprsfile
	java minthint.algorithms.ComputeMinEdit $testfile $rhsexprsfile $outfile

	output=`cat $outfile`
	edit=$(sed "s/^\([0-9]*\):.*$/\1/" <<< $output)
	rhsexpr=$(sed "s/^[^:]*:\([0-9]*\) *$/\1/" <<< $output)
	if [ $rhsexpr -gt 0 ]
	then
		text=$(sed -n "${rhsexpr}{p;q;}" $attrmap)
		rhsexprtext=$(sed "s/^ *$rhsexpr *: *\(.*\)$/\1/" <<< $text)

		rhsexprcorr=`sed -n "${rhsexpr}{p;q;}" $corrarrayfile`

		echo "$typestring $rhsexprtext;" >> $tempfile
	fi

	if [ $edit -eq -1 ]
	then
		continue;
	fi

	if [ $edit == 0 ]
	then
		if [ $(echo " $corr > $maxcorr" | bc) -eq 1 ]
		then
			maxcorr=$corr
		fi
		echo "Retain $rhsexprtext" >> $hintsfile

		lineno=`grep -n "^$rhsexpr$" $rhsexprsfile | cut -d: -f1`
		sed -i "${lineno}d" $rhsexprsfile
		#lineno=`expr $lineno + 1`
		sed -i "${lineno}d" $rhsexprsfile
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
		if [ $(echo " $s > $maxcorr" | bc) -eq 1 ]
		then
			maxcorr=$s
		fi
		echo "Replace $rhsexprtext with $exprtext" >> $hintsfile

		lineno=`grep -n "^$rhsexpr$" $rhsexprsfile | cut -d: -f1`
		sed -i "${lineno}d" $rhsexprsfile
		#lineno=`expr $lineno + 1`
		sed -i "${lineno}d" $rhsexprsfile
	else
		if [ $(echo " $corr > $maxcorr" | bc) -eq 1 ]
		then
			maxcorr=$corr
		fi
		echo "Insert $exprtext" >> $hintsfile
	fi
	fi
done < $compoundhintsexprsfile

java minthint.algorithms.ComputeRemovalNodes $completerhsfile $tempfile $removefile $rhsexprsfile

while read line
do
	text=$(sed -n "${line}{p;q;}" $attrmap)
	exprtext=$(sed "s/^ *$line *: *\(.*\)$/\1/" <<< $text)
	corr=`sed -n "${line}{p;q;}" $corrarrayfile`
	echo "Remove $exprtext" >> $hintsfile
	if [ $(echo " $corr > $maxcorr" | bc) -eq 1 ]
	then
		maxcorr=$corr
	fi
done < $removefile

while read line
do
	echo -n "$line and " >> $comphintsfile
done < $hintsfile

echo ", $maxcorr" >> $comphintsfile

sed -i "s/and ,/,/" $comphintsfile

rm -f $testfile $outfile $removefile $tempfile $hintsfile
