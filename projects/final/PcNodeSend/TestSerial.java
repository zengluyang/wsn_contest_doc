import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class TestSerial implements MessageListener {

  public static final int w_ = 0;
  public static final int a_ = 1;
  public static final int s_ = 2;
  public static final int d_ = 3;
  public static final int __ = 4;
  public static final int _1 = 5;
  public static final int _2 = 6;
  public static final int _3 = 7;
  public static final int _4 = 8;
  public static final int _5 = 9;
  public static final int _6 = 10;
  public static final int _7 = 11;
  public static final int _8 = 12;
  public static final int _9 = 13;
  public static final int _A = 14;
  public static final int _B = 15;
  public static final int _C = 16;
  public static final int _D = 17;
  public static final int _E = 18;
  public static final int _F = 19;
  public static final int r_ = 20;

  private MoteIF moteIF;
  
  public TestSerial(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new TestCarMsg(), this);
  }

/*
  public void sendPackets() {
    int counter = 0;
    TestCarMsg payload = new TestCarMsg();
    
    try {
      while (true) {
	     System.out.println("Sending packet " + counter);
	     payload.set_seq(counter);
	     moteIF.send(0, payload);
	     counter++;
       try {
        Thread.sleep(1000);
      }
	     catch (InterruptedException exception) {}
      }
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
  }*/

  public void messageReceived(int to, Message message) {
    //TestCarMsg msg = (TestCarMsg)message;
    //System.out.println("Received packet sequence number " + msg.get_seq());
  }
  
  private static void usage() {
    System.err.println("usage: TestSerial [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    int counter=0;
    System.out.println("argc: "+ args.length);
    if (args.length == 3) {
      //if (!args[0].equals("-comm")) {
      //  usage();
      //  System.exit(1);
      //}
      source = args[1];
      counter = Integer.parseInt(args[2]);

    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    TestSerial serial = new TestSerial(mif);
    int c;
    TestCarMsg payload = new TestCarMsg();
    while((c=System.in.read()) != -1) {
      //System.out.print((char) c);
      System.out.println("\n"+counter);
      payload.set_seq(counter++);
      switch (c) {
        case 'w':
          payload.set_cmd(w_);
          break;
        case 'a':
          payload.set_cmd(a_);
          break;
        case 's':
          payload.set_cmd(s_);
          break;
        case 'd':
          payload.set_cmd(d_);
          break;
        case ' ':
          payload.set_cmd(__);
          break;
        case '0':
          payload.set_cmd(_1);
          break;
        case '1':
          payload.set_cmd(_2);
          break;
        case '2':
          payload.set_cmd(_3);
          break;
        case '3':
          payload.set_cmd(_4);
          break;
        case '4':
          payload.set_cmd(_5);
          break;
        case '5':
          payload.set_cmd(_6);
          break;
        case '6':
          payload.set_cmd(_7);
          break;
        case '7':
          payload.set_cmd(_8);
          break;
        case '8':
          payload.set_cmd(_9);
          break;
        case '9':
          payload.set_cmd(_A);
          break;
        case 'A':
          payload.set_cmd(_B);
          break;
        case 'B':
          payload.set_cmd(_C);
          break;
        case 'C':
          payload.set_cmd(_D);
          break;
        case 'D':
          payload.set_cmd(_E);
          break;
        case 'E':
          payload.set_cmd(_F);
          break;
        case 'r':
          payload.set_cmd(r_);
      }
        serial.moteIF.send(0, payload);
    }
  }


}
