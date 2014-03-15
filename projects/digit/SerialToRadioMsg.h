#ifndef SerialToRadioMsg_H_
#define SerialToRadioMsg_H_



#define START_WAIT 1000;
#define SEND_DELTA 2000;

enum
{
	MY_AM_ID = 0xC8
};

typedef nx_struct test_send_msg {
  nx_uint8_t  number;
  nx_uint8_t  color;
  nx_uint8_t  count;
}test_send_msg_t;

#endif
