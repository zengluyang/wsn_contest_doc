#include "RadioMsg.h"
#include "test_car_msg.h"
//#define USE_PRINT
//#define SIM
//#define DEBUG

configuration RadioToLedsAppC {}
implementation {
	components MainC;
	components RadioToLedsC as App;
	components LedsC;
	components new AMSenderC(MY_AM_ID);
	components new AMReceiverC(MY_AM_ID);
	components ActiveMessageC;
	components SerialActiveMessageC as SerialAM;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer2;
	
	App.Boot -> MainC.Boot;
	App.Receive -> AMReceiverC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;

	App.Leds -> LedsC;

	App.Packet -> AMReceiverC;
	App.SerialReceive -> SerialAM.Receive[AM_TEST_SERIAL_MSG];
	App.SerialPacket -> SerialAM;
	App.SerialControl -> SerialAM;
	
	App.MilliTimer -> Timer0;
	App.ResendTimer -> Timer1;
	App.SendTimer -> Timer2;
}