#ifndef SimpleRouting_H
#define SimpleRouting_H 

enum {
  AM_BEACON = 7,//DATA
  AM_CONTROL = 10,//RFS
  AM_ROUTE = 11//ROUTE
};

enum {
	NOR,	//normal node
	SRC,	//source node	
	DST,	//destination node
	PSP,	//potential speaker
	SP 		//speaker
};

typedef nx_struct BeaconMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint8_t  data[40];
} BeaconMsg;


typedef nx_struct ControlMsg {
	nx_uint16_t nodeid;
	nx_uint16_t metric;
} ControlMsg;

typedef nx_struct RouteMsg{
	nx_uint16_t nodeid;
	nx_uint16_t metric;
} RouteMsg;

#endif