1.���ݰ��ṹ����SerialToRadioMsg.h:
typedef nx_struct test_send_msg {
  nx_uint8_t  number; //������Ϣ
  nx_uint8_t  color;  //��ɫ��Ϣ
  nx_uint8_t  count;  //���ļ�����
}test_send_msg_t;
2.�������ע�Ᵽ�ַ��书��Ϊ1������Ƶ�οɸ���������������
3.��¼�ڵ�
4.ͨ��PC������˽ڵ㷢������ָʾ�����磺��Ҫ��ʾled2��ɫ����7�����������п�ͨ����Ŀ¼��java����SendPkt��ڵ㷢��ָʾ������������ʾ:
  java SendPkt -comm serial@/dev/ttyUSB0:telosb 07 02
  ����ϰ��ƽ̨�Ͽɽ�07 02���봮��ͨ��payload���֣����ڵ��յ���������ʱ���������ֺ���ɫ��Ϣ�㲥��ȥ��