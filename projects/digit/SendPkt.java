
import net.tinyos.util.*;
import net.tinyos.packet.*;
import java.io.*;

public class SendPkt {
		
    public static void main(String[] argv) throws IOException {
        PacketSource sfw;
        int realLen = 5+8; // sizeof(setting_t)+8 in TestNetwork.h
		int dataLen = argv.length + 8;
        int dataOff = 0;

        if (argv[0].equals("-comm")) {
            sfw = BuildSource.makePacketSource(argv[1]);
            dataOff = 2;
            dataLen -= 2;
        }
        else {
            sfw = BuildSource.makePacketSource();
        }
		// datalen=3+8
		
        byte[] packet = new byte[realLen];

        sfw.open(PrintStreamMessenger.err);

        // set the preamble: see TinyOS tutorials: Mote-PC communications
        packet[0] = (byte)0x00; // start of message
        // destination address
        packet[1] = (byte)0xff; packet[2] = (byte)0xff;
        // link source address
        packet[3] = (byte)0x00; packet[4] = (byte)0x0f;
        // message length
        packet[5] = (byte)realLen; //(byte)0x17;
        // group id
        packet[6] = (byte)0x3f;
        // amtype
        packet[7] = (byte)7; 

		int i=0;
		
        for (i = 0; i < dataLen-8 && i < realLen-8; i++) {
            packet[i+8] = (byte)Integer.parseInt(argv[i+dataOff], 16);
        }
	if (dataLen < realLen) {
          for ( ; i<realLen-8; i++) {
            packet[i+8] = 0;
        }
        }
        try {
            sfw.writePacket(packet);
        }
        catch (IOException e) {
            System.exit(2);
        }
        Dump.printPacket(System.out, packet);
        System.out.println();
        // A close would be nice, but javax.comm's close is deathly slow
        sfw.close();
        System.exit(0);
    }
}    
