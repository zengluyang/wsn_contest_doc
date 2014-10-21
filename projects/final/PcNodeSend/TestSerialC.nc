

#include "../include/test_car_msg.h"


module TestSerialC {
  uses {
    interface SplitControl as Control;
    interface Boot;
    interface Receive;
    interface Packet;

    interface AMSend as RadioSend;
    interface Packet as RadioPacket;
    interface SplitControl as RadioControl;
    interface Leds;
  }
}
implementation {

  message_t packet;

  bool locked = FALSE;
  bool radio_locked = FALSE;
  uint16_t seq = 0;
  
  event void Boot.booted() {
    call Control.start();
    call RadioControl.start();
    call Leds.led0On();
    call Leds.led1On();
    call Leds.led2On();
  }
  
  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    if (len != sizeof(test_car_msg_t )) {return bufPtr;}
    else {
      test_car_msg_t * rcm = (test_car_msg_t *)payload;
      test_car_msg_t * scm = (test_car_msg_t *)call RadioPacket.getPayload(&packet, sizeof(test_car_msg_t ));
      if(rcm == NULL) {return bufPtr;}
      scm->seq=rcm->seq;
      scm->cmd=rcm->cmd;
      if(call RadioSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_car_msg_t))) {
        radio_locked =TRUE;
      }
      call Leds.led0Toggle();
      return bufPtr;
    }
  }


  event void RadioSend.sendDone(message_t* bufPtr, error_t error) {
    radio_locked = FALSE;
    call Leds.led1Toggle();
  }

  event void Control.startDone(error_t err) {
    if (err == SUCCESS) {
      //good
    } else {
      call Control.start();
    }
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      //good
    } else {
      call RadioControl.start();
    }
  }  

  event void RadioControl.stopDone(error_t err) {}


  event void Control.stopDone(error_t err) {}
}




