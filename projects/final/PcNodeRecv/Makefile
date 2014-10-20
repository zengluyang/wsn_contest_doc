COMPONENT=TestSerialAppC
CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -DNEW_PRINTF_SEMANTICS
CFLAGS += -DPRINTF_BUFFER_SIZE=1024

BUILD_EXTRA_DEPS += TestSerial.class
CLEAN_EXTRA = *.class TestCarMsg.java

TestSerial.class: TestDataMsg.java
	javac -target 1.4 -source 1.4 TestSerial.java

TestDataMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=TestDataMsg test_data_msg.h test_data_msg -o $@

include $(MAKERULES)

