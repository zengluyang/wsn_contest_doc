#include "RadioMsg.h"
#define USE_PRINT

configuration RadioToLedsAppC {}
implementation {
	components MainC;
	components RadioToLedsC as App;
	components LedsC;
	components new AMSenderC(MY_AM_ID);
	components new AMReceiverC(MY_AM_ID);
	components ActiveMessageC;
	components SerialActiveMessageC as SerialAM;
	components new TimerMilliC();

	#ifdef USE_PRINT
	components SerialPrintfC;
	components SerialStartC;
	#endif
	
	App.Boot -> MainC.Boot;
	App.Receive -> AMReceiverC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Leds -> LedsC;
	App.Packet -> AMReceiverC;
	App.SerialReceive -> SerialAM.Receive[AM_TEST_SERIAL_MSG];
	App.SerialSend -> SerialAM.Send[AM_TEST_SERIAL_MSG];
	App.TimerMilliC -> TimerMilliC;
}