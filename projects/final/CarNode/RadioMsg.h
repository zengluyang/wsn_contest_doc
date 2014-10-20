#ifndef RadioMsg_H_
#define RadioMsg_H_

enum
{
	MY_AM_ID = 0xC8
};

typedef nx_struct test_send_msg {
  nx_uint16_t  max;
  nx_uint16_t  min;
}test_send_msg_t;

typedef nx_struct test_serial_msg {
  nx_uint16_t     ID;
  nx_uint16_t      number;
} test_serial_msg_t;

enum {
  AM_TEST_SERIAL_MSG = 200,
};


#endif