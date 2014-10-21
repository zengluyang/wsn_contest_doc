#init the printf client
java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSBXXX:telosb

#pc

#no line buffer for terminal
stty -icanon min 1
#nbf

#PcSend Java client
java TestSerial --comm serial@/dev/ttyUSBXXX:telosb 100
#ps
