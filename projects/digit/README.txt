1.数据包结构声明SerialToRadioMsg.h:
typedef nx_struct test_send_msg {
  nx_uint8_t  number; //数字信息
  nx_uint8_t  color;  //颜色信息
  nx_uint8_t  count;  //更改计数器
}test_send_msg_t;
2.编译程序，注意保持发射功率为1，无线频段可根据自身需求设置
3.烧录节点
4.通过PC串口向此节点发送命令指示，例如：需要显示led2颜色数字7，在命令行中可通过本目录下java工具SendPkt向节点发送指示，命令如下所示:
  java SendPkt -comm serial@/dev/ttyUSB0:telosb 07 02
  在练习云平台上可将07 02输入串口通信payload部分，当节点收到串口命令时，它将数字和颜色信息广播出去。