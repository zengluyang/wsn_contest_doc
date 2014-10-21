COMPONENT=TestSerialAppC
CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -DNEW_PRINTF_SEMANTICS
CFLAGS += -DPRINTF_BUFFER_SIZE=1024
# channels from 11 to 26
CFLAGS+=-DCC2420_DEF_CHANNEL=20
# transmission power from 1 to 31
CFLAGS+=-DCC2420_DEF_RFPOWER=31


BUILD_EXTRA_DEPS += TestSerial.class
CLEAN_EXTRA = *.class TestDataMsg.java

TestSerial.class: TestDataMsg.java
	javac -target 1.4 -source 1.4 TestSerial.java

TestDataMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=TestDataMsg ../include/test_data_msg.h test_data_msg -o $@

include $(MAKERULES)

