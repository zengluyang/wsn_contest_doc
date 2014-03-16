#include "Timer.h"
#include "RadioMsg.h"
#include "printf.h"



module RadioToLedsC {
	uses {
		interface Boot;
		interface SplitControl as AMControl;
		interface Packet;
		interface AMSend;
		interface Receive;
		interface Leds;
	}
}

implementation {
	bool busy = FALSE;
	message_t packet;
	uint8_t received_counts[256];

	uint16_t send_count = 0;

	event void Boot.booted() {
		uint16_t i=0;
		printf("RadioToLedsC BOOT\n");
		//call Leds.led0On();
		//call Leds.led1On();
		//call Leds.led2On();
		for(i=0;i<256;i++) {
			received_counts[i]=0;
		}
		call AMControl.start();
	}


	

	event void AMControl.startDone(error_t err) {
		if(err==SUCCESS) {
			//good!
		} else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error) {}

	event message_t* Receive.receive(message_t *msg, 
		void *payload, uint8_t len) {
		test_send_msg_t *rm;
		uint16_t on = 0; //important! cannot be bool
		uint8_t count = (rm->count)%256;
		packet = *msg;
		
		if(len == sizeof(test_send_msg_t)) {
			rm = (test_send_msg_t *) payload;
			on = (PATTERN[rm->number].frag[3-(TOS_NODE_ID/16)%4]) & (0x1<<(TOS_NODE_ID%16));
			printf("RadioToLedsC RECV %d %d %d %d %d %d\n",
				TOS_NODE_ID, 
				rm->number, 
				rm->color, 
				rm->count,
				(on==0 ? 1 : 0),
				send_count
			);
			//printf("sizeof(PATTERN): %d\n",sizeof(PATTERN));
			//printf("PATTERN[0].frag[3-(11/16)%%4] %0x\n",PATTERN[0].frag[3-(11/16)%4]);
			switch((rm->color)%4) {
				case 0:
					if(on!=0) call Leds.led0On();
					else call Leds.led0Off();
					break;
				case 1:
					if(on!=0) call Leds.led1On();
					else call Leds.led1Off();
					break;
				case 2:
					if(on!=0) call Leds.led2On();
					else call Leds.led1Off();
					break;
				default:	
					break;
			}
			//printf("RadioToLedsC received_counts[rm->count] %d\n", received_counts[rm->count]);
			if(!busy && received_counts[rm->count]==0) {
				if(call AMSend.send(AM_BROADCAST_ADDR, 
					&packet, sizeof(test_send_msg_t))) {
					received_counts[rm->count] = 1;
					send_count++;
					busy = TRUE;
					printf("RadioToLedsC SEND %d %d %d %d %d %d\n",
						TOS_NODE_ID,
						rm->number,
						rm->color,
						rm->count,
						(on== 0 ? 1 : 0),
						send_count
					);
				}
			}
		}
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error) 
	{
		busy=FALSE;
	}


}