#include "Timer.h"
#include "RadioMsg.h"
#include "printf.h"

#define END_TIME_SEC 60*25
#define STAUTS_STABLE_TIME_THD_SEC 10
#define STALE_COUNT_THD 2

module RadioToLedsC {
	uses {
		interface Boot;
		interface SplitControl as AMControl;
		interface Packet;
		interface AMSend;
		interface Receive;
		interface Leds;
		interface Receive as SerialReceive;
		interface AMSend as SerialSend;
		interface Timer<TMilli> as MilliTimer;
	}
}

implementation {
	bool busy_radio = FALSE;
	bool busy_serial = FALSE;

	message_t packet;

	uint16_t send_count = 0;
	uint16_t self_number = 0;
	uint16_t self_id = 0;
	
	uint16_t stale_count = 0;
	uint16_t serial_received = FALSE;

	uint16_t time_count = 0; //in seconds
	uint16_t status_stable_count = 0;

	test_send_msg_t status = {0,0};
	test_send_msg_t last_status = {0+1,0+1};

	event void Boot.booted() {
		uint16_t i=0;
		printf("RadioToLedsC BOOT\n");
		call AMControl.start();
	}

	event void MilliTimer.fired() {
		if
		(
			(status_stable_count>=STAUTS_STABLE_TIME_THD_SEC && TOS_NODE_ID==0) || //stablized
			(++time_count>=END_TIME_SEC && TOS_NODE_ID==0) // out of time
		) {
			printf("GreenOrbs %x %x\n",status.min,status.max);
			printfflush();
		}
		if(last_status.max==status.max && last_status.min==status.min) {
			status_stable_count++;
		} else {
			status_stable_count=0;
		}
		last_status.max = status.max;
		last_status.max = status.min; 
	}

	event void AMControl.startDone(error_t err) {
		if(err==SUCCESS) {
			//good!
			call MilliTimer.startPeriodic(1000);			
			self_number = TOS_NODE_ID;
			self_id = TOS_NODE_ID;
			status.min=self_number;
			status.max=self_number;
			last_status.min=self_number+1;
			last_status.max=self_number+1;
		} else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error) {}

	event message_t* Receive.receive(message_t *msg, 
		void *payload, uint8_t len) {
		test_send_msg_t *rm;
		uint16_t on = 0; //important! cannot be bool
		//uint8_t count = (rm->count)%256;
		uint8_t not_stale = FALSE;
		packet = *msg;
		
		if(len == sizeof(test_send_msg_t)) {
			rm = (test_send_msg_t *) payload;
			printf("RadioToLedsC RECV %d %d %d\n",
				TOS_NODE_ID, 
				rm->max, 
				rm->min
			);
			if(status.max >rm->max && status.min < rm->min) {
				if(stale_count++ < STALE_COUNT_THD) {
					not_stale = TRUE;
				}
			}
			if(rm->max > status.max) {
				status.max = rm->max;
				not_stale = TRUE;
				stale_count = 0;
			}
			if(rm->min < status.min) {
				status.min = rm->min;
				not_stale = TRUE;
				stale_count = 0;
			}

			//printf("RadioToLedsC received_counts[rm->count] %d\n", received_counts[rm->count]);
			if(!busy_radio && not_stale && serial_received && TOS_NODE_ID!=0) {
				if(call AMSend.send(AM_BROADCAST_ADDR, 
					&packet, sizeof(test_send_msg_t))) {
					send_count++;
					busy_radio = TRUE;
					printf("RadioToLedsC SEND %d %d %d %d\n",
						TOS_NODE_ID,
						status.max,
						status.min,
						send_count
					);
				}
			}
		}
		printfflush();
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error) 
	{
		busy_radio=FALSE;
	}

	event void SerialSend.sendDone(message_t *msg, error_t error) 
	{
		busy_radio=FALSE;
	}

	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len != sizeof(test_serial_msg_t)) {return bufPtr;}
		else if(!serial_received){
			test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
		  	self_id = rcm->ID;
		  	self_number = rcm->number;
		  	status.min = rcm->number;
		  	status.max = rcm->number;
		  	serial_received = TRUE;
		  	return bufPtr;
		}
	}

}