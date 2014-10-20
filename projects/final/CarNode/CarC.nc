configuration CarC {  
  provides 
  {
    interface SplitControl as CarControl;
	interface Car;
  }
}

implementation {
  components CarP;
  components new Msp430Uart0C() as Resourceusart0;

  components HplMsp430GeneralIOC as GIO;
  CarP.P20 -> GIO.Port20;
  
  components HplMsp430Usart0C;
  CarP.Usart -> HplMsp430Usart0C;
  CarP.Interrupts -> HplMsp430Usart0C;

  CarP.uart0resource -> Resourceusart0;  //test resource
  components LedsC;
  CarP.Leds->LedsC;
  
  Car = CarP.Car;
  CarControl = CarP.CarControl;

  //components new TimerMilliC() as Timer0;
 // components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer1;
	CarP.Timer1 -> Timer1;


}

 
