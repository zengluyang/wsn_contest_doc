COMPONENT = BeaconAppC

CFLAGS += -DTOSH_DATA_LENGTH=114
# channels from 11 to 26
CFLAGS += -DCC2420_DEF_CHANNEL=20
# transmission power from 1 to 31
CFLAGS += -DCC2420_DEF_RFPOWER=1
CFLAGS += -I$(TOSDIR)/lib/printf
include $(MAKERULES)

