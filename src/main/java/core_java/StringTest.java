package core_java;

import java.io.Console;
import java.util.Properties;

public class StringTest {
	
	public static void main(String[] args){
		Console console = System.console();
		if(console!=null){
			char[] passwd = console.readPassword();
			System.out.println(new String(passwd));
		}else{
			System.out.println("Can't read password secretly!");
		}
		int sum = 0;
		for(int i=0; i<10; i++){
			sum += p(i);
		}
		System.out.println(sum);
		System.out.println(p(10));
		System.out.println(System.getProperty("user.home", "."));
		Properties ps = System.getProperties();
		for(Object key : ps.keySet()){
			System.out.println(key + " : " + ps.getProperty(key.toString()));
		}
	}
	
	private static int p(int n){
		int sum = 1;
		for(int i=1; i<=n; i++){
			sum *= i;
		}
		
		return sum;
	}
/*
 *  S00P1_PURGE_RECYCLEBIN_1
	/home/ap/bkbat/log/S00/20140717/S00P1_PURGE_RECYCLEBIN_1.log
	0
	bktransdb:S00T1_Cmpt_Ent_Parm_Inf:Bfr_1_OprgDay_Prd\
	bkbatdb:S00T1_Cmpt_Ent_Parm_Inf:Bfr_1_OprgDay_Prd
	CN000
	parm
	
	select Bfr_1_OprgDay_Prd+(0)  from S00T1_Cmpt_Ent_Parm_Inf where MULTI_TENANCY_ID = 'CN000'
	
	/usr/local/java/jdk1.6.0_43/jre/bin/java -classpath .:/usr/local/java/jdk1.6.0_43/jre/lib/dt.jar:/usr/local/java/jdk1.6.0_43/jre/lib/tools.jar:/home/ap/bkbat/javalib:/home/ap/bkbat/javalib/jdom-1.0.1.jar:/home/ap/bkbat/javalib/ojdbc6-11.2.0.2.0.jar:/home/ap/bkbat/javalib/bde-javainterface-1.0.2.jar:/home/ap/bkbat/javalib/bde-tools-1.0.2.jar:/home/ap/bkbat/javalib/bde-util-1.0.2.jar:/home/ap/bkbat/javalib/commons-logging-1.1.1.jar:/home/ap/bkbat/javalib/nft-javainterface-1.0.1.jar:/home/ap/bkbat/javalib/ccbCC-1.0.1.jar:/home/ap/bkbat/javalib/datechcsp-1.0.0.jar:/home/ap/bkbat/javalib/jdom-1.0.1.jar:/home/ap/bkbat/javalib/commons-logging-1.1.1.jar:/home/ap/nft/ctn/shared:/home/ap/bkbat/javalib/bk-bat-1.0.0.0.jar batpub.Decode bEtaN9+pZbzHQGr5NKU6tg==|cut -d " " -f2
 */
}
