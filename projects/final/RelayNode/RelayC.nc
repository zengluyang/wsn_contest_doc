#include "../include/test_car_msg.h"

module RelayC {
	uses {
		interface Boot;
		interface SplitControl as AMControl;
		interface AMSend;
		interface Receive;
		interface Packet;

		interface SplitControl as DataControl;
		interface AMSend as DataSend;
		interface Receive as DataReceive;
		interface Packet as DataPacket;
		interface Leds;
	}
}
implementation{
	bool busy_radio = FALSE;
	message_t car_packet;
	message_t data_packet;

	uint32_t pktID = 0;

	event void Boot.booted() {
		//printf("RelayC BOOT\n");
		call AMControl.start();
		call DataControl.start();
	}

	event void AMControl.startDone(error_t err) {
		if(err==SUCCESS) {
			//good!
		} else {
			call AMControl.start();
			
		}
	}

	event void DataControl.startDone(error_t err) {
		if(err==SUCCESS) {
			//good!
		} else {
			call DataControl.start();
		}
	}

	event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {

		test_car_msg_t *rm;	
		test_car_msg_t *tcm;
		if(len == sizeof(test_car_msg_t)) 
		{
			rm = (test_car_msg_t *) payload;
			
			//printf("RelayC RECV %d %d %d\n",
			//	TOS_NODE_ID, 
			//	rm->seq,
			//	rm->cmd);
			//printfflush();
			if(rm->cmd == r_) {
				pktID = 0;
			}

			if(rm->seq > pktID)
			{
				tcm = (test_car_msg_t* )(call Packet.getPayload(&car_packet,sizeof(test_car_msg_t)));
				tcm->seq = rm->seq;
				tcm->cmd = rm->cmd;
				if(!busy_radio)
				{

					if(call AMSend.send(AM_BROADCAST_ADDR, &car_packet, sizeof(test_car_msg_t)))
					{	
						busy_radio = TRUE;
						pktID = tcm->seq;
						//printf("RelayC SEND %d %d %d\n",
						//	TOS_NODE_ID, 
						//	tcm->seq,
						//	tcm->cmd);
						//printfflush();
					}
				}
			}
		}
		call Leds.led0Toggle();
		return msg;
	}

	event message_t* DataReceive.receive(message_t *msg, void *payload, uint8_t len) {

		test_data_msg_t *rm;
		test_data_msg_t* tcm;

		if(len == sizeof(test_data_msg_t)) 
		{
			rm = (test_data_msg_t *) payload;
			
			//printf("RelayC RECV %d %d %d\n",
			//	TOS_NODE_ID, 
			//	rm->seq,
			//	rm->cmd);
			//printfflush();

			tcm = (test_data_msg_t *)(call DataPacket.getPayload(&data_packet,sizeof(test_data_msg_t)));
			tcm->id = rm->id;
			tcm->data = rm->data;
			if(!busy_radio)
			{

				if(call DataSend.send(AM_BROADCAST_ADDR, &data_packet, sizeof(test_data_msg_t)))
				{	
					busy_radio = TRUE;
					//printf("RelayC SEND %d %d %d\n",
					//	TOS_NODE_ID, 
					//	tcm->seq,
					//	tcm->cmd);
					//printfflush();
				}
			}
		}
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error) 
	{
		busy_radio=FALSE;
		call Leds.led1Toggle();
	}

	event void DataSend.sendDone(message_t *msg, error_t error) 
	{
		busy_radio=FALSE;
		call Leds.led2Toggle();
	}

	event void AMControl.stopDone(error_t error) {}

	event void DataControl.stopDone(error_t error) {}
}
