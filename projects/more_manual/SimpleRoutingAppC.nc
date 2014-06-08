#include "SimpleRouting.h"
//#define USE_PRINT

configuration SimpleRoutingAppC {
}
implementation {
	components MainC, ActiveMessageC;

    //components new TimerMilliC() as ControlTimer;

	components new AMReceiverC(AM_BEACON) as AMDataReceiverC;
	components new AMReceiverC(AM_CONTROL) as AMControlReceiverC;
	components new AMReceiverC(AM_ROUTE) as AMRouteReceiverC;

	components new AMSenderC(AM_BEACON) as AMDataSenderC;
	components new AMSenderC(AM_CONTROL) as AMControlSenderC;
	components new AMSenderC(AM_ROUTE) as AMRouteSenderC;

	components SimpleRoutingC as App;

	#ifdef USE_PRINT
	components SerialPrintfC;
	components SerialStartC;
	#endif

	App.Boot -> MainC.Boot;

    //App.ControlTimer -> ControlTimer;

	App.AMControl -> ActiveMessageC;

	App.RoutePacket->AMRouteSenderC;
	App.DataPacket->AMDataSenderC;
	App.ControlPacket->AMControlSenderC;

	App.AMDataReceive -> AMDataReceiverC;
	App.AMControlReceive -> AMControlReceiverC;
	App.AMRouteReceive -> AMRouteReceiverC;

	App.AMDataSend -> AMDataSenderC;
	App.AMControlSend -> AMControlSenderC;
	App.AMRouteSend -> AMRouteSenderC;

	App.AMDataPacket -> AMDataReceiverC;
	App.AMControlPacket -> AMControlReceiverC;
	App.AMRoutePacket -> AMRouteReceiverC;
}