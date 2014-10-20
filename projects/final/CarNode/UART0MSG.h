/**
 *
 * @By rubin
 */

#ifndef UART0_MSG_H
#define UART0_MSG_H

enum {
   AM_RADIO_COUNT_MSG = 0x93,
   Default_Interval = 512, //采样周期
   MAX_DATA = 6,
   SYNC_DATA_SUM = 2,
   MAX_NODATA_TIME = 30
};

#endif
