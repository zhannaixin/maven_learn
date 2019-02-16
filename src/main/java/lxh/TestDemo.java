package lxh;
class MyThread extends Thread{
    private String name;

    public MyThread(String name){
        this.name = name;
    }

    @Override
    public void run(){
        for(int x = 0; x < 10; x++){
            System.out.println(name + ", x = " + x);
        }
    }

}

public class TestDemo {
    public static void main(String[] args){
        new MyThread("Java").start();
        //
        //new MyThread("Java").start();
        new MyThread("C").start();
        new MyThread("C++").start();
    }
}
