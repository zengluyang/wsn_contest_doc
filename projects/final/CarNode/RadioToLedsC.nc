#include "../include/test_car_msg.h"
#include "printf.h"

#define LEFT_SERVO 3800
#define RIGHT_SERVO 1800
#define MID_ANGLE (LEFT_SERVO+RIGHT_SERVO)/2
#define ANGLE_STEP 100
#define MAX_SPEED 320
#define RESEND_INTERVAL_MS 1000
#define RESEND_CNT 5

module RadioToLedsC {
	uses {
		interface Boot;
		interface SplitControl as AMControl;
		interface Packet;
		interface Receive;
		
		interface SplitControl as DataControl;
		interface Packet as DataPacket;
		interface AMSend as DataSend;
		
		interface Car;
		interface SplitControl as CarControl;
		interface Timer<TMilli> as ResendTimer;

		interface Leds;
	}
}

implementation {
	bool busy_radio = FALSE;

	message_t packet;

	uint32_t seq = 0;
	uint16_t angle = MID_ANGLE;
	
	uint16_t id;
	
	uint16_t current_data = 0;
	uint16_t resend_count = 0xfff;

	void sendData();

	event void Boot.booted() {
		call AMControl.start();
		call ResendTimer.startPeriodic(RESEND_INTERVAL_MS);
		call Leds.led0On();
		call Leds.led1On();
		call Leds.led2On();
	}

	event void ResendTimer.fired() {
		if(resend_count++ < RESEND_CNT) {
			sendData();
		}
	}
	event void AMControl.startDone(error_t err) {
		if(err==SUCCESS) {
			//good!
			//call DataControl.start();
			call CarControl.start();
		} else {
			call AMControl.start();
		}
	}
	
	event void DataControl.startDone(error_t error)
	{
		if(error == SUCCESS)
		{
			//good.
		}
		else
		{
			call DataControl.start();
		}
	}
		

	event void AMControl.stopDone(error_t error) {}

	event void DataControl.stopDone(error_t error) {}
	
	event void CarControl.startDone(error_t error)
	{
		if(error == SUCCESS)
		{
			//good!
			call Car.InitLeftServo(LEFT_SERVO);
			call Car.InitRightServo(RIGHT_SERVO);
			call Car.InitMidServo(MID_ANGLE);
			call DataControl.start();
		}
		else
		{
			call CarControl.start();
		}
	}
	
	event void CarControl.stopDone(error_t error) {}
			
	event message_t* Receive.receive(message_t *msg, 
		void *payload, uint8_t len) {
		test_car_msg_t *rm;
		
		if(len == sizeof(test_car_msg_t)) {
			rm = (test_car_msg_t *) payload;
			if(rm->seq > seq) {
				seq = rm->seq;
				switch(rm->cmd)
				{
					case w_:
						call Car.Back(MAX_SPEED);
						break;
					case s_:
						call Car.Forward(MAX_SPEED);
						break;
					case a_:
						if(angle + ANGLE_STEP>LEFT_SERVO) {
							break;
						}
						angle += ANGLE_STEP;
						call Car.Angle(angle);
						break;
					case d_:
						if(angle - ANGLE_STEP<RIGHT_SERVO) {
							break;
						}
						angle -= ANGLE_STEP;
						call Car.Angle(angle);
						break;
					case __:
						call Car.Pause();
						angle = MID_ANGLE;
						call Car.Angle(angle);
						break;
					case _1:
						call Car.QuiryReader(100);
						id = 100;
						break;
					case _2:
						call Car.QuiryReader(101);
						id = 101;
						break;
					case _3:
						call Car.QuiryReader(102);
						id = 102;
						break;
					case _4:
						call Car.QuiryReader(103);
						id = 103;
						break;
					case _5:
						call Car.QuiryReader(104);
						id = 104;
						break;
					case _6:
						call Car.QuiryReader(105);
						id = 105;
						break;
					case _7:
						call Car.QuiryReader(106);
						id = 106;
						break;
					case _8:
						call Car.QuiryReader(107);
						id = 107;
						break;
					case _9:
						call Car.QuiryReader(108);
						id = 108;
						break;
					case _A:
						call Car.QuiryReader(109);
						id = 109;
						break;
					case _B:
						call Car.QuiryReader(110);
						id = 110;
						break;
					case _C:
						call Car.QuiryReader(111);
						id = 111;
						break;
					case _D:
						call Car.QuiryReader(112);
						id = 112;
						break;
					case _E:
						call Car.QuiryReader(113);
						id = 113;
						break;
					case _F:
						call Car.QuiryReader(114);
						id = 114;
						break;
					case r_:
						seq = 0;
						break;
					default:
						break;		
				}
			}
		}
		call Leds.led0Toggle();
		return msg;
	}

	event void Car.readDone(error_t state, uint16_t data)
	{
		if(state == SUCCESS)
		{
			current_data = data;
			resend_count = 0;
			sendData();			
		}
		call Leds.led2Toggle();
	}

	void sendData() {
		test_data_msg_t* tdm_pkt = (test_data_msg_t *) (call DataPacket.getPayload(&packet, sizeof(test_data_msg_t)));
			tdm_pkt->id = id;
			tdm_pkt->data = current_data;
			if(!busy_radio)
			{
				if(call DataSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_data_msg_t)))
				{
					busy_radio = TRUE;
					
					//printf("RadioToLedsC SEND %d %d %d %d\n",
					//		TOS_NODE_ID,
					//		tdm_pkt -> id,
					//		tdm_pkt -> data);
					//printfflush();
				}
			}
			call Leds.led1Toggle();
	}
	
	event void DataSend.sendDone(message_t *msg,error_t error)
	{
		busy_radio = FALSE;
	}
		
}