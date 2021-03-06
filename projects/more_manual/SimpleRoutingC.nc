#include <Timer.h>
#include "printf.h"
#include "SimpleRouting.h"

#define MAX_TABLE_LEN 256
#define RECV_NODE_ID 1

module SimpleRoutingC {
    uses interface Boot;
    uses interface SplitControl as AMControl;

    uses interface Packet as RoutePacket;
    uses interface Packet as DataPacket;
    uses interface Packet as ControlPacket;

    uses interface AMPacket as AMDataPacket;
    uses interface AMPacket as AMRoutePacket;
    uses interface AMPacket as AMControlPacket;

    uses interface AMSend as AMControlSend;
    uses interface AMSend as AMRouteSend;
    uses interface AMSend as AMDataSend;

    uses interface Receive as AMControlReceive;
    uses interface Receive as AMDataReceive;
    uses interface Receive as AMRouteReceive;

    uses interface Random;
    uses interface Timer<TMilli> as Timer0;
    uses interface Timer<TMilli> as Timer1;
}


implementation {
    message_t packet;
    bool busy = FALSE;
    uint8_t type = NOR;
    uint16_t cur_nexthop_node_id;
    uint16_t cur_metric=0xffff;
    uint16_t cur_id=0;
    #define PSP_TABLE_SIZE 255
    bool is_PSP[PSP_TABLE_SIZE]={FALSE};
    bool locked=FALSE;
    uint16_t cnt=1;

    event void Boot.booted(){
        call AMControl.start();
        //printf("SimpleRoutingC BOOT\n");
        if(TOS_NODE_ID == RECV_NODE_ID){
            type=DST;
        }
        //printfflush();
    }

    event void AMControl.startDone(error_t err) {
       
        if (err == SUCCESS) {
            if(type==DST){
                call Timer0.startOneShot(100);
            }
            
        } else {
            call AMControl.start();
        }
    }

    event void Timer0.fired() {
        RouteMsg* rpkt = (RouteMsg*) call RoutePacket.getPayload(&packet, sizeof(RouteMsg));
        if(TOS_NODE_ID==RECV_NODE_ID){
                rpkt->id=cnt;
                rpkt->nodeid=TOS_NODE_ID;
                rpkt->metric=0;
                if(!busy && call AMRouteSend.send(AM_BROADCAST_ADDR,&packet,sizeof(RouteMsg)) == SUCCESS ){
                    //printf("SimpleRoutingC SEND_ROUTE %d %d\n",rpkt->nodeid,rpkt->metric);
                    busy=TRUE;
                    cur_id=cnt;
                    cnt++;
                    if(cnt<=29) {
                        call Timer0.startOneShot(500);
                    } else {
                        call Timer0.startOneShot(3000);
                    }
                }
            }
            //printfflush();
    }
    event void AMControl.stopDone(error_t err) {}

    event void AMControlSend.sendDone(message_t *m, error_t err) {
        ControlMsg* cm = (ControlMsg*) call AMControlSend.getPayload(m, sizeof(ControlMsg));
        busy = FALSE;
        if(err == SUCCESS) {
            
        }
    }

    event void AMDataSend.sendDone(message_t *m, error_t err){
        busy = FALSE;
        if(err == SUCCESS) {
            
        } else {

        }
    }


    event void AMRouteSend.sendDone(message_t *m, error_t err){
        busy = FALSE;
        if(err == SUCCESS) {    
        } else {

        }
    }

    bool isSP(){
        uint8_t i;
        //printf("SimpleRoutingC PSP_TABLE: ");
        for(i=0;i<PSP_TABLE_SIZE;i++){
            if(is_PSP[i]==TRUE){
                //printf("%d ",i);
            }
        }
        //printf("\n");

        for(i=0;i<PSP_TABLE_SIZE;i++){
            if(is_PSP[i]==TRUE){
                return TOS_NODE_ID==i;
            }
        }
        return FALSE;
        //printfflush();
    }

    event message_t* AMDataReceive.receive(message_t *msg, 
        void *payload, uint8_t len) {
        BeaconMsg* bm = (BeaconMsg*) payload;
        BeaconMsg* bpkt;
        ControlMsg* cpkt;
        uint8_t i;
        
        if(len == sizeof(BeaconMsg)) {
            if(call AMDataPacket.destination(msg)==AM_BROADCAST_ADDR){
                type=PSP;
                is_PSP[TOS_NODE_ID]=TRUE;
                cpkt=(ControlMsg*) call ControlPacket.getPayload(&packet,sizeof(ControlMsg));
                cpkt->nodeid=TOS_NODE_ID;
                cpkt->metric=cur_metric;
                if(!busy && !locked && call AMControlSend.send(AM_BROADCAST_ADDR,&packet,sizeof(ControlMsg)) ==SUCCESS ){
                    locked=TRUE;
                    busy=TRUE;
                    //printf("SimpleRoutingC SEND_CONTROL %d %d\n",cpkt->nodeid,cpkt->metric);
                }
            }
            bpkt = (BeaconMsg*)(call DataPacket.getPayload(&packet, sizeof(BeaconMsg)));
            bpkt->nodeid = bm->nodeid;
            bpkt->counter = bm->counter;
            for(i=0;i<40;i++){
                bpkt->data[i]=bm->data[i];
            }
            //printf("SimpleRoutingC SEND_DATA_COND %d %d\n",isSP(),type);
            if(!busy && 
                (isSP() || type==NOR) &&
                (call AMDataPacket.destination(msg)==TOS_NODE_ID || call AMDataPacket.destination(msg)==AM_BROADCAST_ADDR)&& 
                call AMDataSend.send(cur_nexthop_node_id,&packet,sizeof(BeaconMsg)) == SUCCESS) {
                busy=TRUE;
                //printf("SimpleRoutingC SEND_DATA %d %d %d\n",bpkt->nodeid,bpkt->counter,bpkt->data[0]);
            }
        }
        if(DST==type && call AMDataPacket.destination(msg)==TOS_NODE_ID){
            printf("SimpleRoutingC RECV_DATA %d %d %d\n", call AMDataPacket.source(msg),bm->nodeid, bm->counter);
        }
        //printfflush();
        return msg;

    }

    event message_t* AMControlReceive.receive(message_t *msg, 
        void *payload, uint8_t len) {
        ControlMsg *cm= (ControlMsg *)payload;
        ControlMsg* cpkt;
        //printf("SimpleRoutingC RECV_CONTROL %d %d\n",cm->nodeid,cm->metric);
        if(len == sizeof(ControlMsg)){
           
            is_PSP[cm->nodeid]=TRUE;
            if(type==PSP){
                cpkt=(ControlMsg*) call ControlPacket.getPayload(&packet,sizeof(ControlMsg));
                cpkt->nodeid=cm->nodeid;
                cpkt->metric=cm->metric;
                if(!busy && call AMControlSend.send(AM_BROADCAST_ADDR,&packet,sizeof(ControlMsg)) ==SUCCESS){
                    busy=TRUE;
                    //printf("SimpleRoutingC SEND_CONTROL %d %d\n",cpkt->nodeid,cpkt->metric);
                }
            }
        }
        //printfflush();
        return msg;
    }



    event message_t* AMRouteReceive.receive(message_t *msg, 
        void *payload, uint8_t len) {
        RouteMsg* rm = (RouteMsg*) payload;
        RouteMsg* rpkt;
        //printf("SimpleRoutingC RECV_ROUTE %d %d\n", rm->nodeid, rm->metric);
        rpkt = (RouteMsg*) call RoutePacket.getPayload(&packet,sizeof(RouteMsg));
        if(len==sizeof(RouteMsg) && rpkt!=NULL){
            
            if(cur_metric > rm->metric+1){// update route table
                cur_metric = rm->metric+1;
                cur_nexthop_node_id=rm->nodeid;        
                //printf("SimpleRoutingC SEND_ROUTE_BUSY? %d %d %d\n",busy,len==sizeof(RouteMsg),rpkt!=NULL);
                
            }
            /*
            rpkt->nodeid=TOS_NODE_ID;
            rpkt->metric=cur_metric; 
            rpkt->id=rm->id;
            //printf("SimpleRoutingC SEND_ROUTE_COND %d %d %d\n",cur_id,rm->id,busy);
            if(cur_id<rm->id && !busy && call AMRouteSend.send(AM_BROADCAST_ADDR, &packet, sizeof(RouteMsg)) == SUCCESS){// broadcast route table
                    busy = TRUE;
                    cur_id=rm->id;
                    printf("SimpleRoutingC SEND_ROUTE %d %d %d\n",rpkt->id,rpkt->nodeid,rpkt->metric);
            }
            */
            if(cur_id<rm->id) {
                cur_id=rm->id;
                call Timer1.startOneShot(call Random.rand32()%100);
            }
            
        }
        return msg;
        //printfflush();
    }

    event void Timer1.fired() {
        RouteMsg* rpkt;
        rpkt = (RouteMsg*) call RoutePacket.getPayload(&packet,sizeof(RouteMsg));
        rpkt->nodeid=TOS_NODE_ID;
        rpkt->metric=cur_metric; 
        rpkt->id=cur_id;
        if(!busy && call AMRouteSend.send(AM_BROADCAST_ADDR, &packet, sizeof(RouteMsg)) == SUCCESS) {
            printf("SimpleRoutingC SEND_ROUTE %d %d %d\n",rpkt->id,rpkt->nodeid,rpkt->metric);
        }
    }


}


