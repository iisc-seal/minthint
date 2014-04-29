attrmap=$1
corrarrayfile=$2
rhsfile=$3
typefile=$4

temprhsfile="temp.rhs.file"
temptemprhsfile="temp.temp.rhs.file"
tempcompleterhsfile="temp.completerhs.file"

rm -f $temprhsfile

typestring=""
while read line
do
	typestring="$typestring $line"
done < $typefile

while read line
do
	text=$(sed -n "${line}{p;q;}" $attrmap)
	expr=$(sed "s/^ *$line *: *\(.*\)$/\1/" <<< $text)
	echo "$line" >> $temprhsfile
	echo "$typestring $expr;" >> $temprhsfile
done < $rhsfile

head -2 $temprhsfile | tail -1 > $tempcompleterhsfile

cp $temprhsfile $temptemprhsfile
bash shell-scripts/synthsimplehints.sh simplehints $attrmap $temptemprhsfile $corrarrayfile $typefile $tempcompleterhsfile

chintsfile="temp.compoundhints.file"
rm -f $chintsfile

list="compoundhints1 compoundhints2 compoundhints3"
for file in $list
do
	if [ ! -e $file ]
	then
		continue
	fi
	cp $temprhsfile $temptemprhsfile
	bash shell-scripts/synthcompoundhints.sh $file $attrmap $temptemprhsfile $corrarrayfile $typefile $tempcompleterhsfile

	cat temp.comphints.file >> $chintsfile
done

finalhintsfile="final.hints.file"
rm -f $finalhintsfile

cp temp.simplehints.file $finalhintsfile
cat $chintsfile >> $finalhintsfile
sort -r -k 2 -t, $finalhintsfile | awk '!a[$0]++' &> temp.final.hints.file
mv temp.final.hints.file $finalhintsfile

rm -f $temprhsfile $temptemprhsfile $tempcompleterhsfile temp.simplehints.file $chintsfile $file $corrarrayfile
rm -f simplehints compoundhints* expressionsfile partitionsfile temp.comphints.file
