//#include "RadioMsg.h"
//#define USE_PRINT



configuration RadioToLedsAppC {}
implementation {
	components MainC;
	components RadioToLedsC as App;
	components new TimerMilliC() as Timer0;
	#ifdef USE_PRINT
	components SerialPrintfC;
	components SerialStartC;
	#endif
	App.Boot -> MainC.Boot;
	App.Timer0 -> Timer0;
}