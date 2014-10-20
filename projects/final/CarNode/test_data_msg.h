#ifndef TEST_DATA_MSG_H
#define TEST_DATA_MSG_H

typedef nx_struct test_data_msg{
	nx_int16_t id; //tag id
	nx_int16_t data;
} test_data_msg_t;


enum {
	AM_TEST_DATA_MSG = 0x03
};

#endif