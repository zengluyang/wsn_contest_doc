/***************************************************
*     挑战赛 多多益善 数据源节点程序
*     #节点启动后随机一时刻（大于3秒）开始每隔100毫秒广播1个数据包
***************************************************/

#include <Timer.h>
#include "Beacon.h"
#include "printf.h"
module BeaconC {
  uses interface Boot;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Random;
  uses interface Receive;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  event void Boot.booted() {
	call AMControl.start();
	printf("TransC BOOT");
  }

  event void AMControl.startDone(error_t err) {
	if (err == SUCCESS) {
	  call Timer0.startOneShot(3 * 1024 + call Random.rand32() % 100);
	}
	else {
	  call AMControl.start();
	}
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
	  printf("TransC FIRE");
  }
  void sendMsg() {
	uint8_t i;
	printf("TransC SEND");
	  if (!busy) {
		BeaconMsg* btrpkt = (BeaconMsg*)(call Packet.getPayload(&pkt, sizeof(BeaconMsg)));
		if (btrpkt == NULL) {
		  return;
		}
		btrpkt->nodeid = TOS_NODE_ID;
		btrpkt->counter = counter;
		for(i=0;i<40;i++) {
		  btrpkt->data[i]=i+1;
		}   
		if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BeaconMsg)) == SUCCESS) {
		  busy = TRUE;
		}
	}
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
	if (&pkt == msg) {
	  counter++;
	}
	busy = FALSE;
	//call Timer0.startOneShot(100);
  }

event message_t* Receive.receive(message_t* bufPtr, 
		   void* payload, uint8_t len) {
	am_addr_t am_addr;
	printf("TransC RECV");
	dbg("RadioCountToLedsC", "Received packet of length %hhu.\n", len);
	dbg("RadioCountToLedsC", "payload, counter:%hhu.\n", ((BeaconMsg *)payload)->counter);
	dbg("RadioCountToLedsC", "payload, counter:%hhu.\n", ((BeaconMsg *)payload)->counter);
	am_addr=call AMPacket.source(bufPtr);
	dbg("RadioCountToLedsC","Packet Source: %hhu.\n",am_addr);
	if (len != sizeof(BeaconMsg)) {return bufPtr;}
	else {
		//good!
	}
  }
  
}
