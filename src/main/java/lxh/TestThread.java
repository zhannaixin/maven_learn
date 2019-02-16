package lxh;
class MyThreadT extends Thread{
    private String name;

    MyThreadT(String name){
        this.name = name;
    }

    @Override
    public void run(){
        for(int x = 0; x < 10; x++){
            System.out.println(Thread.currentThread().getName() + ": " + name + ", x = " + x);
        }
    }

}

class MyThreadR implements Runnable{
    private String name;

    MyThreadR(String name){
        this.name = name;
    }

    @Override
    public void run(){
        for(int x = 0; x < 10; x++){
            System.out.println(Thread.currentThread().getName() + ": " + name + ", x = " + x);
        }
    }

}

public class TestThread {
    public static void main(String[] args){
        Thread jt = new MyThreadT("Java");
        jt.setName("Java");
        jt.start();

        Thread ct = new MyThreadT("C");
        ct.setName("C");
        ct.start();

        Thread cppt = new MyThreadT("C++");
        cppt.setName("C++");
        cppt.start();

        Thread lt = new Thread(new MyThreadR("Lisp"));
        lt.setName("Lisp");
        lt.start();

        Thread nt = new Thread(new Runnable() {
            @Override
            public void run() {
                for(int x = 0; x < 10; x++){
                    System.out.println(Thread.currentThread().getName() + ", x = " + x);
                }
            }
        });
        nt.setName("NULL");
        nt.start();
    }
}
