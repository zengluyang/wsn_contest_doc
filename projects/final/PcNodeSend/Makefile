COMPONENT=TestSerialAppC

CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -DNEW_PRINTF_SEMANTICS
CFLAGS += -DPRINTF_BUFFER_SIZE=1024


BUILD_EXTRA_DEPS += TestSerial.class
CLEAN_EXTRA = *.class TestCarMsg.java

TestSerial.class: TestCarMsg.java
	javac -target 1.4 -source 1.4 TestSerial.java

TestCarMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=TestCarMsg test_car_msg.h test_car_msg -o $@

include $(MAKERULES)

