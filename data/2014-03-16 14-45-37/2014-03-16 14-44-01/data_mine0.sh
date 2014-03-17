for i in `seq 0 49`
do
	echo -n $i " "
	fgrep -o RECV $i.txt | wc -l
done
