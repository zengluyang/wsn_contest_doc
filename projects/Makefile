zip: digit.zip digit_stupid_broadcast.zip



digit.zip: $(wildcard  digit/*.nc digit/*.h digit/*.c)
	7za a -tzip digit.zip digit

digit_stupid_broadcast.zip: $(wildcard  digit_stupid_broadcast/*.nc digit_stupid_broadcast/*.h digit_stupid_broadcast/*.c)
	7za a -tzip digit_stupid_broadcast.zip digit_stupid_broadcast

clean:
	rm digit.zip digit_stupid_broadcast.zip