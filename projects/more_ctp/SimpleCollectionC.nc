#include "Timer.h"
#include "printf.h"
#include "SimpleCollection.h"

#define MAX_TABLE_LEN 256
#define RECV_NODE_ID 1
module SimpleCollectionC {
	uses interface Boot;
	uses interface SplitControl as AMControl;
	uses interface StdControl as RoutingControl;
	uses interface AMSend as AMControlSend;
	uses interface Send as RoutingSend;
	uses interface RootControl;
	uses interface Receive as AMControlReceive;
	uses interface Receive as AMDataReceive;
	uses interface Receive as RoutingReceive;
}

implementation {
	message_t ControlPacket;
	message_t RoutingPacket;
	bool busy = FALSE;
	uint8_t isSource[MAX_TABLE_LEN] = {0};
	bool controlSent = FALSE;
	//uint8_t isLocked[MAX_TABLE_LEN][2] = {0};



	event void Boot.booted(){
		call AMControl.start();
		printf("SimpleCollectionC BOOT\n");
		//printf("SimpleCollectionC AM_BEACON %d\n",AM_BEACON);
		printfflush();
	}

	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {
	    	call RoutingControl.start();
	    	if(TOS_NODE_ID==RECV_NODE_ID) {
	    		call RootControl.setRoot();
	    	}
	      	
	    } else {
	    	call AMControl.start();
	    }
  	}


  	event void AMControl.stopDone(error_t err) {}

  	event void AMControlSend.sendDone(message_t *m, error_t err) {
  		ControlMsg* cm = (ControlMsg*) call AMControlSend.getPayload(m, sizeof(ControlMsg));
  		if(err == SUCCESS) {
  			busy = FALSE;
  			//isLocked[(cm->nodeid) % MAX_TABLE_LEN] = TRUE;
  			controlSent = TRUE;
  			//printf("SimpleCollectionC LOCK %d %d\n", TOS_NODE_ID, (cm->nodeid) % MAX_TABLE_LEN);
  			printfflush();
  		}
  	}


  	event void RoutingSend.sendDone(message_t *m, error_t err){
  		if(err == SUCCESS) {
  			busy = FALSE;
  		} else {
  			//@TODO re-send route packet
  		}
  	}

  	event message_t* AMDataReceive.receive(message_t *msg, 
		void *payload, uint8_t len) {
  		BeaconMsg* bm = (BeaconMsg*) payload;
  		ControlMsg* cm;
  		BeaconMsg* bmToSend;
  		int i,lowest=MAX_TABLE_LEN;
  		if(len == sizeof(BeaconMsg)) {
  			printf("SimpleCollectionC RECV_DATA %d %d\n", bm->nodeid, bm->counter);
  			/*
            isSource[TOS_NODE_ID] = bm->nodeid;
  			
  			if(!controlSent) {
  				cm = (ControlMsg*) call AMControlSend.getPayload(&ControlPacket, sizeof(ControlMsg));
  				if(!busy && NULL!=cm) {
  					cm->srcNodeid = bm->nodeid;
  					cm->rootNodeid = TOS_NODE_ID;
  					cm->isSource = TRUE;
  					if(call AMControlSend.send(AM_BROADCAST_ADDR, &ControlPacket,sizeof(ControlMsg)) == SUCCESS) {
  						printf("SimpleCollectionC SEND_CTRL %d %d %d\n", cm->srcNodeid, cm->rootNodeid , cm->isSource);
  						busy = TRUE;
  					}
  				}
  			}
  			for(i=0;i<MAX_TABLE_LEN;i++) {
  				if(isSource[i]==bm->nodeid) {
  					lowest=i;
  					break;
  				}				
  			}
  			printf("SimpleCollectionC ROOT_ALG %d\n",lowest);
  			*/
            if(TOS_NODE_ID == 2 || TOS_NODE_ID == 44) {
	  			bmToSend = (BeaconMsg*) call RoutingSend.getPayload(&RoutingPacket, sizeof(BeaconMsg));
	  			if(!busy && bmToSend!=NULL) {
		  			bmToSend->nodeid = bm->nodeid;
	  				bmToSend->counter = bm->counter;
	  				for(i=0;i<40;i++){
	  					bmToSend->data[i] = bm->data[i];
	  				}
		  			if(call RoutingSend.send(&RoutingPacket, sizeof(BeaconMsg)) == SUCCESS) {
		  				printf("SimpleCollectionC SEND_ROUT %d %d\n", bmToSend->nodeid, bmToSend->counter);
		  				busy = TRUE;
		  			}
	  			}
  			}

  		}
  		printfflush();
  		return msg;

  	}

  	event message_t* AMControlReceive.receive(message_t *msg, 
		void *payload, uint8_t len) {
      /*
  		ControlMsg* cm = (ControlMsg*) payload;
  		if(len == sizeof(ControlMsg)) {
  			printf("SimpleCollectionC RECV_CTRL %d %d %d\n", cm->srcNodeid, cm->rootNodeid, cm->isSource);
  			isSource[cm->rootNodeid] = cm->isSource;
  		}
  		printfflush();
  		return msg;
      */
  	}

  	event message_t* RoutingReceive.receive(message_t *msg, 
		void *payload, uint8_t len) {
  		BeaconMsg* bm = (BeaconMsg*) payload;
  		int i=0;
  		if(len == sizeof(BeaconMsg) && call	RootControl.isRoot()) {
  			printf("SimpleCollectionCRoot RECV %d %d ", bm->nodeid, bm->counter);
  			for(;i<40;i++) {
  				printf("%d",bm->data[i]);
  				if(39 == i) {
  					printf("\n");
  				}
  			}
  			printfflush();
  		}
  		return msg;
  	}


}