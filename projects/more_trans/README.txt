1.数据包结构声明Beacon.h：
typedef nx_struct BeaconMsg {
  nx_uint16_t nodeid;    //发送节点id
  nx_uint16_t counter;   //序列号
  nx_uint8_t  data[40];  //数据载荷
} BeaconMsg;
2.编译程序，注意保持发射功率为1，数据载荷部分在评分时将采用特殊编码以验证接收数据完整性，无线频段可根据自身需求设置
3.烧录节点
4.节点将每隔100毫秒广播一个数据包