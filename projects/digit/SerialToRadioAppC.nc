#define USE_PRINT

configuration SerialToRadioAppC{
}
implementation 
{
	components MainC;
	components SerialToRadioC;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMSenderC(MY_AM_ID) as Sender;
	components SerialActiveMessageC;
	#ifdef USE_PRINT
	components SerialPrintfC;
	components SerialStartC;
	#endif
	SerialToRadioC.Boot->MainC.Boot;
	SerialToRadioC.Timer0->Timer0.Timer;
	SerialToRadioC.Packet->ActiveMessageC.Packet;
	SerialToRadioC.AMSend->Sender;
	SerialToRadioC.SerialReceive -> SerialActiveMessageC.Receive[MY_AM_ID];
	SerialToRadioC.AMControl->ActiveMessageC;
	SerialToRadioC.SerialControl -> SerialActiveMessageC;
	SerialToRadioC.SerialPacket -> SerialActiveMessageC;
	
}
