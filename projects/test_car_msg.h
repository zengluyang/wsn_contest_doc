#ifndef TEST_CAR_MSG_H
#define TEST_CAR_MSG_H
enum
{
	w_,
	a_,
	s_,
	d_,
	__,
	_1,
	_2,
	_3,
	_4,
	_5,
	_6,
	_7,
	_8,
	_9,
	_A,
	_B,
	_C,
	_D,
	_E,
	_F
}


typedef nx_struct test_car_msg {
	nx_uint32_t seq;
	nx_uint16_t command;
}

enum {
	TEST_CAR_MSG_AM_ID = 0x02;
}

#endif