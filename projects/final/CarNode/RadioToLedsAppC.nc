#include "RadioMsg.h"
#include "test_car_msg.h"
#include "test_data_msg.h"
//#define USE_PRINT
#define SIM
#define DEBUG

configuration RadioToLedsAppC {}
implementation {
	components MainC;
	components RadioToLedsC as App;
	components LedsC;
	components new AMReceiverC(AM_TEST_CAR_MSG) as CarReceiver;
	components ActiveMessageC as CarActiveMessage;
	
	
	components new AMSenderC(AM_TEST_DATA_MSG) as DataSender;
	components new AMReceiverC(AM_TEST_CAR_MSG) as DataReceiver;
	components ActiveMessageC as DataActiveMessage;
	components CarC;
	components new TimerMilliC() as Timer0;
	
	App.Boot -> MainC.Boot;
	
	App.Receive -> CarReceiver;
	App.AMControl -> CarActiveMessage;
	App.Packet -> CarReceiver;
	
	App.DataSend -> DataSender;
	App.DataControl -> DataActiveMessage;
	App.DataPacket -> DataSender;
	
	App.Car -> CarC.Car;
	App.CarControl -> CarC.CarControl;

	App.ResendTimer -> Timer0;
	App.Leds -> LedsC;
	
}