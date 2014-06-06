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

    //uses interface Timer<Tmilli> as ControlTimer;
}

implementation {
    message_t packet;
    bool busy = FALSE;
    uint8_t type = NOR;
    uint16_t cur_nexthop_node_id;
    uint16_t cur_metric=0xffff;
    #define PSP_TABLE_SIZE 255
    bool is_PSP[PSP_TABLE_SIZE]={FALSE};
    bool locked=FALSE;

    event void Boot.booted(){
        call AMControl.start();
        printf("SimpleRoutingC BOOT\n");
        //printfflush();
    }

    event void AMControl.startDone(error_t err) {
        RouteMsg* rpkt = (RouteMsg*) call RoutePacket.getPayload(&packet, sizeof(RouteMsg));
        if (err == SUCCESS) {
            if(TOS_NODE_ID==RECV_NODE_ID){
                rpkt->nodeid=TOS_NODE_ID;
                rpkt->metric=0;
                if(!busy && call AMRouteSend.send(AM_BROADCAST_ADDR,&packet,sizeof(RouteMsg)) == SUCCESS ){
                    printf("SimpleRoutingC SEND_ROUTE %d %d\n",rpkt->nodeid,rpkt->metric);
                    busy=TRUE;
                }
            }
        } else {
            call AMControl.start();
        }
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
        printf("SimpleRoutingC PSP_TABLE: ");
        for(i=0;i<PSP_TABLE_SIZE;i++){
            if(is_PSP[i]==TRUE){
                printf("%d",i);
            }
        }
        printf("\n");

        for(i=0;i<PSP_TABLE_SIZE;i++){
            if(is_PSP[i]==TRUE){
                return TOS_NODE_ID==i;
            }
        }
    }

    event message_t* AMDataReceive.receive(message_t *msg, 
        void *payload, uint8_t len) {
        BeaconMsg* bm = (BeaconMsg*) payload;
        BeaconMsg* bpkt;
        ControlMsg* cpkt;
        uint8_t i;
        if(len == sizeof(BeaconMsg)) {
            printf("SimpleRoutingC RECV_DATA %d %d\n", bm->nodeid, bm->counter);
            if(call AMDataPacket.destination(msg)==AM_BROADCAST_ADDR){
                type=PSP;
                is_PSP[TOS_NODE_ID]=TRUE;
                cpkt=(ControlMsg*) call ControlPacket.getPayload(&packet,sizeof(ControlMsg));
                cpkt->nodeid=TOS_NODE_ID;
                cpkt->metric=cur_metric;
                if(!busy && !locked && call AMControlSend.send(AM_BROADCAST_ADDR,&packet,sizeof(ControlMsg)) ==SUCCESS ){
                    locked=TRUE;
                    busy=TRUE;
                    printf("SimpleRoutingC SEND_CONTROL %d %d\n",cpkt->nodeid,cpkt->metric);
                }
            }
            bpkt = (BeaconMsg*)(call DataPacket.getPayload(&packet, sizeof(BeaconMsg)));
            bpkt->nodeid = bm->nodeid;
            bpkt->counter = bm->counter;
            for(i=0;i<40;i++){
                bpkt->data[i]=bm->data[i];
            }
            if(!busy && (isSP() || type==NOR) && call AMDataSend.send(cur_nexthop_node_id,&packet,sizeof(BeaconMsg)) == SUCCESS) {
                busy=TRUE;
                printf("SimpleRoutingC SEND_DATA %d %d %d\n",bpkt->nodeid,bpkt->counter,bpkt->data[0]);
            }
        }
        //printfflush();
        return msg;

    }

    event message_t* AMControlReceive.receive(message_t *msg, 
        void *payload, uint8_t len) {
        ControlMsg *cm= (ControlMsg *)payload;
        ControlMsg* cpkt;
        if(len == sizeof(ControlMsg)){
            printf("SimpleRoutingC RECV_CONTROL %d %d\n",cm->nodeid,cm->metric);
            is_PSP[cm->nodeid]=TRUE;
            if(type==PSP){
                cpkt=(ControlMsg*) call ControlPacket.getPayload(&packet,sizeof(ControlMsg));
                cpkt->nodeid=cm->nodeid;
                cpkt->metric=cm->metric;
                if(!busy && call AMControlSend.send(AM_BROADCAST_ADDR,&packet,sizeof(ControlMsg)) ==SUCCESS){
                    busy=TRUE;
                    printf("SimpleRoutingC SEND_CONTROL %d %d\n",cpkt->nodeid,cpkt->metric);
                }
            }
        }
    }



    event message_t* AMRouteReceive.receive(message_t *msg, 
        void *payload, uint8_t len) {
        RouteMsg* rm = (RouteMsg*) payload;
        RouteMsg* rpkt = (RouteMsg*) call RoutePacket.getPayload(&packet,sizeof(RouteMsg));
        
        if(len==sizeof(RouteMsg) && rpkt!=NULL){
            printf("SimpleRoutingC RECV_ROUTE %d %d\n", rm->nodeid, rm->metric);
            if(cur_metric > rm->metric+1){
                cur_metric = rm->metric+1;
                cur_nexthop_node_id=rm->nodeid;
                rpkt->nodeid=TOS_NODE_ID;
                rpkt->metric=cur_metric;
                if(!busy && call AMRouteSend.send(AM_BROADCAST_ADDR, &packet, sizeof(RouteMsg)) == SUCCESS){
                    busy = TRUE;
                    printf("SimpleRoutingC SEND_ROUTE %d %d\n",rpkt->nodeid,rpkt->metric);
                }
            }
        }
        return msg;
    }


}


