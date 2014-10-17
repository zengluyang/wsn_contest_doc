/*************************************************************************
    > File Name: TestInput.java
    > Author: ma6174
    > Mail: ma6174@163.com 
    > Created Time: 2014年10月16日 星期四 23时45分21秒
 ************************************************************************/
public class TestInput {
	public static void main(String[] args) throws java.io.IOException {
		int c;
		while((c=System.in.read()) != -1) {
			System.out.print((char) c);
		}
	}
}
