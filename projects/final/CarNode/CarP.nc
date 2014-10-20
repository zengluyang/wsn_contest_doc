//author :rubin
//@greenorbs
//2011-4-12 fix some bug
//when you start to call co2sensor.read(),you will get the data per 6second 
//if you want to start the overtime detect ,you just start timer0 in co2sensor.read();
//init when the co2data can not return in 30 seconds ,the program will signal err

//#include "pr.h"
#include "Timer.h"
#include "UART0MSG.h"
#define WARM_UP_PERIOD (100*1024UL)

#define BUF_MAX     100    //ï¿œï¿œï¿œï¿œï¿œï¿œó³€¶ï¿œ
#define CMD_LENTH   7      //ï¿œï¿œï¿œî³€ï¿œï¿œ

#define ReaderCMD_LENTH   1      //Reader
//#define WARM_UP_PERIOD (100*1024UL)

#define SERVO       1      //×ªï¿œï¿œ
#define FORWARD     2      //Ç°ï¿œï¿œ
#define BACK        3      //ï¿œï¿œï¿œï¿œ
#define STOP        4      //Í£Ö¹
#define QUIRYREADER 11


#define INIT_SERVO_LEFT   5
#define INIT_SERVO_RIGHT  6
#define INIT_SERVO_MID   7
#define INIT_MOTOR_MAX   8
#define INIT_MOTOR_MIN   9

  


module CarP {
    provides interface SplitControl as CarControl;
    provides interface Car;
	uses 
    {
	interface Resource as uart0resource;  //testresource ok
        interface HplMsp430Usart as Usart;
        interface HplMsp430UsartInterrupts as Interrupts;
	interface HplMsp430GeneralIO as P20;
        interface Leds;
	//	interface Timer<TMilli> as Timer1;
		 interface Timer<TMilli> as Timer1;

		
    }
}

implementation 
{

	bool isStart = FALSE;        //ï¿œï¿œï¿œï¿œï¿œï¿œÖŸ
	bool isSend = FALSE;
	error_t statetag = FAIL;
	uint8_t  CarCommand[CMD_LENTH] = {1,2,1,0,0,255,255};  //ï¿œï¿œï¿œÍµï¿œï¿œï¿œï¿œîŽ®
	bool isUartDataOk = FALSE;
	uint8_t rcvSyncDataSum = 0;//receive 0xFF, 0xFF,
	uint8_t SyncData[SYNC_DATA_SUM] = {255, 255};  //sync data  
	uint8_t recdata[MAX_DATA]; //œÓÊÕÊýŸÝŽæŽ¢
	uint8_t nreading = 0; //œÓÊÕŒÆÊý
	bool isBufFull = FALSE;
	uint16_t tagdata = 0;
	uint32_t co2OnInstant = 0;
	uint32_t co2OnTime = 0;
    uint8_t cmdlength = 0;

	uint16_t noDataTime=0;

 	task void recvTask();

	msp430_uart_union_config_t config1 = {
		{utxe : 1, 
		 urxe : 1, 
		 ubr : UBR_1MHZ_115200, //Baud rate (use enum msp430_uart_rate_t for predefined rates)
		 umctl : UMCTL_1MHZ_115200, //Modulation (use enum msp430_uart_rate_t for predefined rates)
		 ssel : 0x02,        //Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
		 pena : 0,           //Parity enable (0=disabled; 1=enabled)
		 pev : 0,            //Parity select (0=odd; 1=even)
		 spb : 0,            //Stop bits (0=one stop bit; 1=two stop bits)
		 clen : 1,           //Character length (0=7-bit data; 1=8-bit data)
		 listen : 0,         //Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
		 mm : 0,             //Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
		 ckpl : 0,           //Clock polarity (0=normal; 1=inverted)
		 urxse : 0,           //Receive  -edge detection (0=disabled; 1=enabled)
		 urxeie : 0,          //Erroneous-character receive (0=rejected; 1=recieved and URXIFGx set)
		 urxwie : 0,          //Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)     
		 utxe : 1,            // 1:enable tx module
		 urxe : 1             // 1:enable rx module
		}
    };
	 
	    
     void SendString(uint8_t*ptr, uint8_t len)
     {   
        uint8_t i = 0;   
        for(i =0;  i < len; i++,*ptr++)
        {
            call Usart.tx(*ptr);
            while(!call Usart.isTxEmpty()); //ç­åŸåéçŒå­äžºç©ºïŒå³åéå®æ
			
	   }
    }
	async event void Interrupts.txDone()
    {
      //do nothing;  
		////pr("send\n");
    }  
	command error_t CarControl.start()
	{
		isStart = TRUE;							//ï¿œï¿œï¿œï¿œ
//		call uart0resource.request();      	//ï¿œï¿œï¿œóŽ®¿ï¿œï¿œï¿œÔŽ
		signal CarControl.startDone(SUCCESS);	//ï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œ
		return SUCCESS;	
	}
	
	
	command error_t CarControl.stop()
	{
	    isStart = FALSE;        //ÎŽï¿œï¿œï¿œï¿œ×ŽÌ¬
	    isSend = FALSE;
		signal CarControl.stopDone(SUCCESS);
        return SUCCESS;	
	}
	
 	command error_t Car.Angle(uint16_t value)
	{
        cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02;
		if(isStart == TRUE &&  isSend == FALSE)
        {	
			isSend = TRUE;
			CarCommand[2] = SERVO;   					//ï¿œï¿œï¿œï¿œï¿œÍµï¿œï¿œï¿œï¿œï¿œÐŽï¿œëµœï¿œï¿œ3ï¿œÖœï¿œ
			CarCommand[4] =  (uint8_t) (value & 0x00ff); 	//ï¿œï¿œuint16_tï¿œï¿œï¿œï¿œ×ªï¿œï¿œÎ»ï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œuint8_t
			value = value >> 8;
			CarCommand[3] =  (uint8_t)value;
    		call uart0resource.request();      	//ï¿œï¿œï¿œóŽ®¿ï¿œï¿œï¿œÔŽ
        }
        else
            return EBUSY;      
		return SUCCESS;
	}
	
	command error_t Car.Forward(uint16_t value)
	{
		
		cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02;
		if(isStart == TRUE && isSend == FALSE)
		{
			isSend = TRUE;
			
			CarCommand[2] = FORWARD; //ï¿œï¿œï¿œï¿œï¿œÍµï¿œï¿œï¿œï¿œï¿œÐŽï¿œëµœï¿œï¿œ3ï¿œÖœï¿œ
			CarCommand[4] = (uint8_t)(value & 0x00ff); //ï¿œï¿œuint16_tï¿œï¿œï¿œï¿œ×ªï¿œï¿œÎ»ï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œuint8_t
			value = value >> 8;
			CarCommand[3] = (uint8_t) value;
			call uart0resource.request(); //ï¿œï¿œï¿œóŽ®¿ï¿œï¿œï¿œÔŽ
		}
		else
			return EBUSY;
		return SUCCESS;
	}
	
	command error_t Car.Back(uint16_t value)
	{
		cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02;
		if(isStart == TRUE && isSend == FALSE)
		{
			isSend = TRUE;
			CarCommand[2] = BACK; //ï¿œï¿œï¿œï¿œï¿œÍµï¿œï¿œï¿œï¿œï¿œÐŽï¿œëµœï¿œï¿œ3ï¿œÖœï¿œ
			CarCommand[4] = (uint8_t)(value & 0x00ff); //ï¿œï¿œuint16_tï¿œï¿œï¿œï¿œ×ªï¿œï¿œÎ»ï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œï¿œuint8_t
			value = value >> 8;
			CarCommand[3] = (uint8_t) value;
			call uart0resource.request();//ï¿œï¿œï¿œóŽ®¿ï¿œï¿œï¿œÔŽ
		}
		else
			return EBUSY;
		return SUCCESS;	
	}
	//use for reader
	
	command error_t Car.QuiryReader(uint8_t value)
	{
		//pr("quiry cmd :%x \n",value);
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02;
		cmdlength = 4;
		if(isStart == TRUE && isSend == FALSE)
		{
			isSend = TRUE;
			CarCommand[2] = QUIRYREADER; 
			CarCommand[3] =  value;
			call uart0resource.request(); //ï¿œï¿œï¿œóŽ®¿ï¿œï¿œï¿œÔŽ
		}
		else
			{
		//call Timer1.startPeriodic(2048UL);
		//call uart0resource.request();
		nreading=0;
		isBufFull=FALSE;
		isUartDataOk=FALSE;

		return EBUSY;
			
			}
			return SUCCESS;
	}
	command error_t Car.Pause()
	{
		cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02;
		if(isStart == TRUE && isSend == FALSE)
		{
			isSend = TRUE;
			CarCommand[2] = STOP; //ï¿œï¿œï¿œï¿œï¿œÍµï¿œï¿œï¿œï¿œï¿œÐŽï¿œëµœï¿œï¿œ3ï¿œÖœï¿œ
			CarCommand[3] = 0x00;
			CarCommand[4] = 0x00;
			call uart0resource.request(); //ï¿œï¿œï¿œóŽ®¿ï¿œï¿œï¿œÔŽ
		}
		else
			return EBUSY;
		return SUCCESS;
		
	}


	command error_t Car.InitMaxSpeed(uint16_t value)
    {
        	cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02;
	if(isStart == TRUE &&  isSend == FALSE)
        {   
            isSend = TRUE;
            CarCommand[2] = INIT_MOTOR_MAX;                      //锟斤拷锟斤拷锟酵碉拷锟斤拷锟斤拷写锟诫到锟斤拷3锟街斤拷
            CarCommand[4] =  (uint8_t) (value & 0x00ff);    //锟斤拷uint16_t锟斤拷锟斤拷转锟斤拷位锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷uint8_t
            value = value >> 8;
            CarCommand[3] =  (uint8_t)value;
            call uart0resource.request();       //锟斤拷锟襟串匡拷锟斤拷源
        }
        else
            return EBUSY;      
        return SUCCESS;
    }
    
   command error_t Car.InitMinSpeed(uint16_t value)
    {
        	cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02;
	if(isStart == TRUE &&  isSend == FALSE)
        {   
            isSend = TRUE;
            CarCommand[2] = INIT_MOTOR_MIN;                      //锟斤拷锟斤拷锟酵碉拷锟斤拷锟斤拷写锟诫到锟斤拷3锟街斤拷
            CarCommand[4] =  (uint8_t) (value & 0x00ff);    //锟斤拷uint16_t锟斤拷锟斤拷转锟斤拷位锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷uint8_t
            value = value >> 8;
            CarCommand[3] =  (uint8_t)value;
            call uart0resource.request();       //锟斤拷锟襟串匡拷锟斤拷源
        }
        else
            return EBUSY;      
        return SUCCESS;
    }
    
    command error_t Car.InitLeftServo(uint16_t value)
    {
       		cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02; 
	if(isStart == TRUE &&  isSend == FALSE)
        {   
            isSend = TRUE;
            CarCommand[2] = INIT_SERVO_LEFT;                      //锟斤拷锟斤拷锟酵碉拷锟斤拷锟斤拷写锟诫到锟斤拷3锟街斤拷
            CarCommand[4] =  (uint8_t) (value & 0x00ff);    //锟斤拷uint16_t锟斤拷锟斤拷转锟斤拷位锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷uint8_t
            value = value >> 8;
            CarCommand[3] =  (uint8_t)value;
            call uart0resource.request();       //锟斤拷锟襟串匡拷锟斤拷源
        }
        else
            return EBUSY;      
        return SUCCESS;
    }
    
    command error_t Car.InitRightServo(uint16_t value)
    {
        
		cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02; 
	if(isStart == TRUE &&  isSend == FALSE)
        {   
            isSend = TRUE;
            CarCommand[2] = INIT_SERVO_RIGHT;               //锟斤拷锟斤拷锟酵碉拷锟斤拷锟斤拷写锟诫到锟斤拷3锟街斤拷
            CarCommand[4] =  (uint8_t) (value & 0x00ff);    //锟斤拷uint16_t锟斤拷锟斤拷转锟斤拷位锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷uint8_t
            value = value >> 8;
            CarCommand[3] =  (uint8_t)value;
            call uart0resource.request();       //锟斤拷锟襟串匡拷锟斤拷源
        }
        else
            return EBUSY;      
        return SUCCESS;
    }
    
    command error_t Car.InitMidServo(uint16_t value)
    {
      		cmdlength = 7;
		CarCommand[0] = 0x01;
		CarCommand[1] = 0x02; 
	 if(isStart == TRUE &&  isSend == FALSE)
        {   
            isSend = TRUE;
            CarCommand[2] = INIT_SERVO_MID;                 //锟斤拷锟斤拷锟酵碉拷锟斤拷锟斤拷写锟诫到锟斤拷3锟街斤拷
            CarCommand[4] =  (uint8_t) (value & 0x00ff);    //锟斤拷uint16_t锟斤拷锟斤拷转锟斤拷位锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷uint8_t
            value = value >> 8;
            CarCommand[3] =  (uint8_t)value;
            call uart0resource.request();       //锟斤拷锟襟串匡拷锟斤拷源
        }
        else
            return EBUSY;      
        return SUCCESS;
    }
 
	
	event void uart0resource.granted()
	{
		 // You are now in control of the resource.
	    
		call Usart.setModeUart(&config1);  	//ï¿œï¿œÊŒï¿œï¿œï¿œï¿œï¿œï¿œ
		call Usart.enableUart();   			//ï¿œï¿œï¿œï¿œï¿œÕ·ï¿œÊ¹ï¿œï¿œ
		call Usart.enableRxIntr();   		//ï¿œï¿œï¿œï¿œï¿œÐ¶ï¿œÊ¹ï¿œï¿œ
		U0CTL &= ~SYNC;      				//UART0ï¿œï¿œÊŒï¿œï¿œÎªUARTÄ£Êœ 
		SendString(CarCommand,cmdlength);
		if(cmdlength==4)
		//call Timer1.startOneShot(2000);
			call Timer1.startOneShot(1000);
			////pr("in the rxdone to release the resource\n");
		else
		{	call uart0resource.release();   // must release the bus
			isSend = FALSE;
		}
	}
	
  	event void Timer1.fired()
    {
		////pr("timer0 fired \n");
		
		
		
		 
		statetag = FAIL;
			post recvTask();
			//pr("overtime\n");
		

		    
	}
	//ï¿œÐ¶Ïœï¿œï¿œï¿œï¿œÂŒï¿œ
     async event void Interrupts.rxDone(uint8_t data)
    {
		//check 0xff 0xff
		
		if(isUartDataOk == FALSE &&(call uart0resource.isOwner() == TRUE))
		{
			if(SyncData[rcvSyncDataSum] == data)
			{
			   rcvSyncDataSum++;
			   if(rcvSyncDataSum == SYNC_DATA_SUM)
			   {
				  ////pr("ok ---\n");
				  isUartDataOk = TRUE;
				  nreading = 0;
			   }
			}
			else
			{
				rcvSyncDataSum = 0;




			}
			return;
		}
	
		if(isBufFull == FALSE &&isUartDataOk == TRUE&&(call uart0resource.isOwner() == TRUE))
		{
			if(nreading < MAX_DATA)
			{
				recdata[nreading++] = data;
			}
			if(nreading == MAX_DATA)
			{             
				isBufFull = TRUE;
				call Timer1.stop();
				
				//match the syc data
				if((recdata[0] ==0x00) && (recdata[1] == 0x00))	
				{
					//get the tag data 
					tagdata = recdata[MAX_DATA-2]*256 + recdata[MAX_DATA-1];
					statetag = SUCCESS;
					
					post recvTask();
				}
				else
				{
					statetag = FAIL;	
					post recvTask();	
				}
			}
// adding time control
			/*else	
			{	
				call Timer1.startOneShot(WARM_UP_PERIOD);				
				}*/
		}
	}
  
	task void recvTask()
  {
	// //pr("in task %d \n",stateCo2);
	uint8_t i = 0;
	call Timer1.stop();
	for( i = 0;i<MAX_DATA;i++)
	{
		//pr("%x\n",recdata[i]);
	}
	isBufFull = FALSE;
	isUartDataOk = FALSE;
	rcvSyncDataSum = 0;
	nreading = 0;
	if (statetag == FAIL)
	{
		signal Car.readDone(statetag,0xFFFF);
		//pr("error %x\n",tagdata);
		isSend = FALSE;
		   // must release the bus
	}
	else
	{
		signal Car.readDone(statetag,tagdata);
		//pr("success %x\n",tagdata);
		isSend = FALSE;
	}
	call uart0resource.release();
  }

}

