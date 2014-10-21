#include "test_car_msg.h"
#include "test_data_msg.h"

configuration RelayAppC {}
implementation {
	components MainC;
	components RelayC as App;
	components new AMSenderC(AM_TEST_CAR_MSG);
	components new AMReceiverC(AM_TEST_CAR_MSG);

	components new AMSenderC(AM_TEST_DATA_MSG) as DataSender;
	components new AMReceiverC(AM_TEST_DATA_MSG) as DataReceiver;
	components ActiveMessageC as DataActiveMessage;

	components ActiveMessageC;
	components LedsC;

	App.Boot -> MainC.Boot;
	App.Receive -> AMReceiverC;
	App.AMSend -> AMSenderC;
	App.Packet -> AMReceiverC;
	App.AMControl -> ActiveMessageC;

	App.DataReceive -> DataReceiver;
	App.DataSend -> DataSender;
	App.DataControl -> DataActiveMessage;
	App.DataPacket -> DataReceiver;
	App.Leds -> LedsC;

}