

#include "../include/test_data_msg.h"
#include "printf.h"

module TestSerialC {
  uses {
    interface SplitControl as Control;
    interface Boot;
    interface Receive;
    interface Packet;
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
  }
  
  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    test_data_msg_t *rm;
    if (len != sizeof(test_data_msg_t )) {return bufPtr;}
    else {
      rm = (test_data_msg_t *)bufPtr;
      printf("TAG %d DATA %d\n",rm->id,rm->data);
      printfflush();
      return bufPtr;
    }
  }

  event void Control.startDone(error_t err) {
    if (err == SUCCESS) {
      //good
    } else {
      call Control.start();
    }
  }

  event void Control.stopDone(error_t err) {}
}




