package basic;

import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static java.lang.System.out;

class A{}

class B extends A implements Cloneable{
    private int i, j;

    B(){}

    B(int _i, int _j){
        i = _i;
        j = _j;
    }

    @Override
    public boolean equals(Object obj){
        if(!(obj instanceof B)){
            return false;
        }

        B b = (B)obj;
        return i == b.i && j == b.j;
    }

    @Override
    public int hashCode(){
        return Objects.hash(i, j);
    }

    /**
     * 按照惯例，此方法返回的对象应该独立于该对象（正被复制的对象）。
     * 要获得此独立性，在 super.clone 返回对象之前，有必要对该对象的一个或多个字段进行修改。
     * 这通常意味着要复制包含正在被复制对象的内部“深层结构”的所有可变对象，
     * 并使用对副本的引用替换对这些对象的引用。
     *
     * 如果一个类只包含基本字段或对不变对象的引用，那么通常不需要修改 super.clone 返回的对象中的字段。
     * @return 克隆的新对象
     * @throws CloneNotSupportedException 不支持克隆异常
     */
    @Override
    protected Object clone() throws CloneNotSupportedException{
//        B b = (B)super.clone();
//        b.i = i;
//        b.j = j;
//        return b;
        return super.clone();
    }

    @Override
    public String toString(){
        return "[i = " + i + ", j = " + j + "]";
    }
}

public class TestObject {

    /**
     * 注意：不要求程序在两次运行期间返回同样结果
     * 如果a.equals(b)返回true，那么a.hashCode()应该与b.hashCode()相等。
     * 如果a.equals(b)返回false，不要求a.hashCode()与b.hashCode()不相等，
     *  但为不相等的对象生成不同整数结果可以提高哈希表的性能。
     *
     * 由Object 类定义的hashCode方法确实会针对不同的对象返回不同的整数。

     * */
    private static void testHashCode() throws CloneNotSupportedException {
        out.println("Test hashCode() ================================================================================");
        A a1 = new A();
        A a2 = new A();
        out.println("a1.hashCode: " + a1.hashCode());//1349414238
        out.println("a2.hashCode: " + a2.hashCode());//157627094

        A b1 = new B();
        A b2 = new B();
        out.println("b1.hashCode: " + b1.hashCode());//961
        out.println("b2.hashCode: " + b2.hashCode());//961

        //移动此块代码，会影响输出--默认的hashCode返回值可能与内存地址有关
        a1 = new A();
        a2 = new A();
        out.println("a1.hashCode: " + a1.hashCode());//932607259    745160567  610984013
        out.println("a2.hashCode: " + a2.hashCode());//1740000325   610984013  1644443712

        b1 = new B();
        b2 = new B();
        B b3 = (B)(((B) b1).clone());
        out.println("b1.hashCode: " + b1.hashCode());//961
        out.println("b2.hashCode: " + b2.hashCode());//961
        out.println("b3.hashCode: " + b3.hashCode());//961
    }

    /**
     * 自反性、对称性、传递性、一致性
     */
    private static void testEquals() throws CloneNotSupportedException {
        A a1 = new A();
        A a2 = new A();
        out.println("Test equals() ==================================================================================");
        out.println("a1.equals(a2): " + a1.equals(a2));      //false

        B b1 = new B(1, 2);
        A b2 = new B(1, 2);
        B b3 = (B)b1.clone();
        out.println("b1.equals(b2): " + b1.equals(b2));     //true
        out.println("b1.equals(null): " + b1.equals(null)); //false
        out.println("b3.equals(b2): " + b3.equals(b2));     //true
        out.println("b3: " + b3);     //true
    }

    /**
     * notify/notifyAll方法只应由作为此对象监视器的所有者的线程来调用。
     * 否则会抛出java.lang.IllegalMonitorStateException
     *
     * 通过以下三种方法之一，线程可以成为此对象监视器的所有者：
     * 通过执行此对象的同步实例方法。
     * 通过执行在此对象上进行同步的 synchronized 语句的正文。
     * 对于 Class 类型的对象，可以通过执行该类的同步静态方法。
     *
     *
     * wait方法在其他线程调用此对象的 notify() 方法或 notifyAll() 方法，或者超过指定的时间量前，导致当前线程等待。
     * 当前线程必须拥有此对象监视器。
     *
     * 此方法导致当前线程（称之为 T）将其自身放置在对象的等待集中，然后放弃此对象上的所有同步要求。
     *
     * 出于线程调度目的，在发生以下四种情况之一前，线程 T 被禁用，且处于休眠状态：      *
     * 其他某个线程调用此对象的 notify 方法，并且线程 T 碰巧被任选为被唤醒的线程。
     * 其他某个线程调用此对象的 notifyAll 方法。
     * 其他某个线程中断线程 T。
     * 大约已经到达指定的实际时间。但是，如果 timeout 为零，则不考虑实际时间，在获得通知前该线程将一直等待。
     *
     *
     * 一次只能有一个线程拥有对象的监视器。
     *
     * @throws InterruptedException 中断异常
     */
    private static void testThread() throws InterruptedException {
        out.println("Test notify wait ===============================================================================");
        A a = new A();

        long oStart = System.currentTimeMillis();
        out.println(Thread.currentThread().getName() + "\t" + oStart);
        ExecutorService es = Executors.newCachedThreadPool();

        es.submit(() -> {
            long start = System.currentTimeMillis();
            out.println(Thread.currentThread().getName() + "\t" + start);
            try {
                synchronized (a) {
                    out.println(Thread.currentThread().getName());
                    a.wait(5000); //放弃此对象上的所有同步要求
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            long end = System.currentTimeMillis();
            out.println(Thread.currentThread().getName() + "\t" + end + "\t" + (end - start));
        });

        es.submit(() -> {
            long start = System.currentTimeMillis();
            out.println(Thread.currentThread().getName() + "\t" + start);
            try {
                Thread.sleep(50);
                synchronized (a) {//线程1wait后，会让出锁，这里不会有等待
                    out.println(Thread.currentThread().getName());
                    a.wait(100);
                    a.notify();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            long end = System.currentTimeMillis();
            out.println(Thread.currentThread().getName() + "\t" + end + "\t" + (end - start));
        });

        es.submit(() -> {
            long start = System.currentTimeMillis();
            out.println(Thread.currentThread().getName() + "\t" + start);
            try {
                Thread.sleep(800);
                synchronized (a) {
                    out.println(Thread.currentThread().getName());
                    a.wait(400);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            long end = System.currentTimeMillis();
            out.println(Thread.currentThread().getName() + "\t" + end + "\t" + (end - start));
        });

        Thread.sleep(2000);
        es.shutdown();
        long oEnd = System.currentTimeMillis();
        out.println(Thread.currentThread().getName() + "\t" + oEnd + "\t" + (oEnd - oStart));
    }


    public static void main(String[] args) throws Exception {
        testHashCode();

        testEquals();

        testThread();

    }
}
