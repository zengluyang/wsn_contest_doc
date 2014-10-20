#init the printf client
java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSBXXX:telosb


#no line buffer for terminal
stty -icanon min 1
