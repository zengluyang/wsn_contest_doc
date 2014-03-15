#include <Timer.h>
#include "Beacon.h"
configuration BeaconAppC {
}
implementation {
  components MainC;
  components RandomC;
  components BeaconC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_BEACON);
  components new AMReceiverC(AM_BEACON);
  components SerialPrintfC;
  components SerialStartC;

  App.Boot -> MainC;
  App.Random -> RandomC;
  App.Timer0 -> Timer0;
  App.Packet -> AMReceiverC;
  App.AMPacket -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMReceiverC;
  App.Receive -> AMReceiverC;
}
