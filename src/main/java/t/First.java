package t;

/**
 * Created by Administrator on 14-1-21.
 */
public class First {
    public static void main(String[] args) {
//        for (int i = 0; i < 10; i++) {
//            new Thread(t.First::p).start();
//        }
//        Runnable

        SubExFirst subExFirst = new SubExFirst();
        subExFirst.tun();
        subExFirst.fun();
    }

    static void p() {
        System.out.println(Thread.currentThread().getId() + ":\t" + Thread.currentThread().getName());
    }

    private void q() {

    }
    public void fun(){
        System.out.println("in class t.First!");
    }
}

abstract class ExFirst extends First implements f, f2 {
    private int i;
//    void p() {}
//private  void tun(){}
    private void q() {
        // i=0;
    }
//    public void fun(){
//        System.out.println("in class t.ExFirst!");
//    }
}

class SubExFirst extends ExFirst {
    @Override
    public void tun() {
        System.out.println("in class t.SubExFirst!");
    }
}

interface f {
    default void fun() {
        System.out.println("in interface t.f!");
    }

    void tun();
}

interface f2{
    void fun();

}