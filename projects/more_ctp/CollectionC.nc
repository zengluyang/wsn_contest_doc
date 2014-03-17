#include "Timer.h"
#include "printf.h"
#include "Collection.h"

module CollectionC {
	uses interface Boot;
	uses interface SplitControl as AMControl;
	uses interface StdControl as RoutingControl;
	uses interface Send;
	uses interface RootControl;
	uses interface Receive;
}

implementation {
	message_t pacakge;
	bool busy=false;


	event void Boot.booted(){
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {
	    	call RoutingControl.start();
	    	if(TOS_NODE_ID==0) {
	    		call RootControl.setRoot();
	    	}
	      	
	    } else {
	    	call AMControl.start();
	    }
  	}


  	event void AMControl.stopDone(error_t err) {}

  	void sendMessage() {
  		BeaconMsg* bm = (BeaconMsg*) call AMSend.getPayload(&packet, sizeof(BeaconMsg));
  		if(!busy && bm!=NULL) {
  			// @TODO
  			if(call Send.send(&packet, sizeof(BeaconMsg)) == SUCCESS) {
  				busy = TRUE;
  			}
  		}
  	}

  	event void Send.sendDone(message_t *m, error_t err) {
  		if(err == SUCCESS) {
  			busy = FALSE;
  		}
  	}

  	event message_t* Receive.receive(message_t *msg, 
		void *payload, uint8_t len) {

  	}


}