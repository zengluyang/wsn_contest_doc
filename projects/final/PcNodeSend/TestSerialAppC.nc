#include "test_car_msg.h"

configuration TestSerialAppC {}
implementation {
  components TestSerialC as App, LedsC, MainC;
  components SerialActiveMessageC as AM;
  components ActiveMessageC;

  components new AMSenderC(AM_TEST_CAR_MSG);

  App.Boot -> MainC.Boot;
  App.Control -> AM;
  App.Receive -> AM.Receive[AM_TEST_CAR_MSG];
  App.Packet -> AM;

  App.RadioControl -> ActiveMessageC;
  App.RadioSend -> AMSenderC;
  App.RadioPacket -> AMSenderC;
}


