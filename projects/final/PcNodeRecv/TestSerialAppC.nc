#include "test_data_msg.h"

configuration TestSerialAppC {}
implementation {
  components TestSerialC as App, LedsC, MainC;

  components ActiveMessageC;

  components new AMReceiverC(AM_TEST_DATA_MSG);

  App.Boot -> MainC.Boot;

  App.Control -> ActiveMessageC;
  App.Receive -> AMReceiverC;
  App.Packet -> AMReceiverC;
}


