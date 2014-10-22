import java.io.IOException;


class TestContinue {
	public static void main(String[] args) throws IOException{
		int c;
		while((c=System.in.read()) != -1) {
			switch (c) {
				case 'w':
					System.out.println("W!");
					break;
				case 'a':
					System.out.println("A!");
					break;
				default :
					continue;
					//break;
			}
			System.out.println("Send!");
		}
	}
}