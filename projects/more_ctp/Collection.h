#ifndef Collection_H
#define Collection_H 

enum {
  AM_BEACON = 7 
};

typedef nx_struct BeaconMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint8_t  data[40];
} BeaconMsg;

#Collection_H