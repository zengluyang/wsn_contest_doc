/******************************************************
*    挑战赛 数字接龙 0号节点程序
******************************************************/

#include "Timer.h"
#include "SerialToRadioMsg.h"
#include "printf.h"

#define START_WAIT 1000
#define SEND_DELTA 2000



const uint8_t number_array[10] = {
	9,8,7,6,5,4,3,2,1,0
};

const uint8_t color_array[3] = {
	2,1,0
};

module SerialToRadioC{
	uses
	{
		interface Boot;
		interface Timer<TMilli>	as Timer0;	
		interface SplitControl as AMControl;
		interface SplitControl as SerialControl;
		interface Packet;
		interface AMSend;
		interface Receive as SerialReceive;
		interface Packet as SerialPacket;
	}
}

implementation
{
	bool busy=FALSE;
	message_t packet;
	message_t serial_msg;
	uint8_t count=0;
	//uint8_t send_count=0;
	event void Boot.booted() 
	{
		call AMControl.start();
		call Timer0.startOneShot(START_WAIT);
	}

	event void AMControl.startDone(error_t err)
	{
		if(err==SUCCESS)
		{
			call SerialControl.start();
		}
		else 
			call AMControl.start();
	}

	event void SerialControl.startDone(error_t err) {}
	event void AMControl.stopDone(error_t error) {}
	event void SerialControl.stopDone(error_t err) {}	
	
	event void Timer0.fired() 
	{
		
		test_send_msg_t *rm = (test_send_msg_t*)call SerialPacket.getPayload(&serial_msg,sizeof(test_send_msg_t));
		test_send_msg_t *send = (test_send_msg_t*)call AMSend.getPayload(&packet,sizeof(test_send_msg_t));
		printf("SerialToRadioC FIRE %d %d %d\n",send->number,send->color,send->count);
		send->number = number_array[send->count%10];
		send->color  = color_array[send->count%3];
		send->count = count;
		if(!busy && count<2)
		{
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_send_msg_t))==SUCCESS)
		  	{
		  		printf("SerialToRadioC SEND %d %d %d\n",send->number,send->color,send->count);
		  		count++;
		  		busy=TRUE;
		  		call Timer0.startOneShot(SEND_DELTA);
		  	}			
		}
		
	}
	
	event void AMSend.sendDone(message_t *msg, error_t error) 
	{
		busy=FALSE;
	}

	event message_t * SerialReceive.receive(message_t *msg, void *payload, uint8_t len) 
	{		
		serial_msg = *msg;
 		call Timer0.startOneShot(10);
		return msg;
	}	
	
	
}
