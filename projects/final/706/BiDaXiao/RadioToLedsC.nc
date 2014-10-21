#include "Timer.h"
#include "RadioMsg.h"
#include "test_car_msg.h"
#include "printf.h"

#define END_TIME_SEC 60*4
#define STAUTS_STABLE_TIME_THD_SEC 10
#define STALE_COUNT_THD 1
#define RESEND_INTERVAL_MS 200

#define ROOT_NODE_ID 0

#ifdef DEBUG
#warning "DEBUG defined. printing debug msg. don't define DEBUG for real contest!"
#endif


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
		interface Packet as SerialPacket;
		interface SplitControl as SerialControl;
		interface Timer<TMilli> as MilliTimer;
		interface Timer<TMilli> as ResendTimer;
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

	uint16_t result_sent = FALSE;

	test_send_msg_t status = {0,0};
	test_send_msg_t last_status = {0+1,0+1};

	void sendStatus();

	event void Boot.booted() {
		#ifdef DEBUG
		#endif
		call SerialControl.start();
		call AMControl.start();
	}

	event void MilliTimer.fired() {
		#ifdef DEBUG
		#endif
		if
		(
			(status_stable_count>=STAUTS_STABLE_TIME_THD_SEC && TOS_NODE_ID==ROOT_NODE_ID) || //stablized
			(++time_count>=END_TIME_SEC && TOS_NODE_ID==ROOT_NODE_ID) // out of time
		) {
			if(!result_sent) {
				printf("GreenOrbs %x %x\n",status.min,status.max);
				printfflush();
				result_sent = TRUE;
			}
		}
		if(last_status.max==status.max && last_status.min==status.min) {
			status_stable_count++;
		} else {
			status_stable_count=0;
		}
		last_status.max = status.max;
		last_status.min = status.min;

	}

	event void ResendTimer.fired() {
		#ifdef DEBUG
		#endif
		sendStatus();
	}

	void sendStatus() {
		if(serial_received && TOS_NODE_ID!=ROOT_NODE_ID) {
			if(!busy_radio) {
				test_send_msg_t* tsm = (test_send_msg_t* )(call Packet.getPayload(&packet,sizeof(test_send_msg_t)));
				if(tsm==NULL) {
					call ResendTimer.startOneShot(RESEND_INTERVAL_MS);
					return ;
				}
				tsm->max=status.max;
				tsm->min=status.min;
				if(call AMSend.send(AM_BROADCAST_ADDR, 
					&packet, sizeof(test_send_msg_t))) {
					send_count++;
					busy_radio = TRUE;
					#ifdef DEBUG
					#endif
				}
			} else {
				call ResendTimer.startOneShot(RESEND_INTERVAL_MS);
			}
		}
		return;
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
			#ifdef SIM
			#warning "SIM defined using TOS_NODE_ID as number! don't define SIM for real contest!\n"
			#endif
		} else {
			call AMControl.start();
		}
	}


	event void AMControl.stopDone(error_t error) {}

	event void SerialControl.startDone(error_t err) {
		if(err==SUCCESS) {

			} else {
				call SerialControl.start();
			}
	}

	event void SerialControl.stopDone(error_t err) {}

	event message_t* Receive.receive(message_t *msg, 
		void *payload, uint8_t len) {
		test_send_msg_t *rm;
		uint8_t not_stale = FALSE;
		packet = *msg;
		
		if(len == sizeof(test_send_msg_t)) {
			rm = (test_send_msg_t *) payload;
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
			#ifdef DEBUG
			#endif
			if(not_stale) {
				sendStatus();
			}
		}
		printfflush();
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error) 
	{
		busy_radio=FALSE;
		if(error == SUCCESS) {
			//good! 
		} else {
				call ResendTimer.startOneShot(RESEND_INTERVAL_MS);
		}
	}

	event void SerialSend.sendDone(message_t *msg, error_t error) 
	{
		busy_serial=FALSE;
	}

	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len != sizeof(test_serial_msg_t)) {return bufPtr;}
		else if(!serial_received){
			test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
			#ifdef DEBUG
			#endif;
		  	self_id = rcm->ID;
		  	self_number = rcm->number;
		  	status.min = rcm->number;
		  	status.max = rcm->number;
		  	serial_received = TRUE;
		  	sendStatus();
		  	return bufPtr;
		}
	}

}