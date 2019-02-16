package lambda;


import java.util.concurrent.Callable;
import java.util.function.Function;
import java.util.function.Supplier;


/**
 * Lambda表达式
 * 1.参数
 * 2.返回值
 */

interface IUserDAO {
    void insert(User u);
}

interface IOrderDAO {
    int order(Order o);
}

public class LambdaTest {
    public static void main(String[] args) throws Exception {
        Runnable r1 = () -> {
            System.out.println("Thread 1.");
        };
        Thread t1 = new Thread(r1);
        t1.start();


        Runnable r2 = () -> System.out.println("Thread 2.");
        Thread t2 = new Thread(r2);
        t2.start();

        Runnable r3 = new Runnable() {
            @Override
            public void run() {
                System.out.println("Thread 3.");
            }
        };
        Thread t3 = new Thread(r3);
        t3.start();


        Callable<String> c1 = new Callable<String>() {
            @Override
            public String call() throws Exception {
                return "C1";
            }
        };
        System.out.println(c1.call());

        Callable<String> c2 = () -> "C2";
        System.out.println(c2.call());

        Callable<String> c3 = () -> {
            return "C3";
        };
        System.out.println(c3.call());

        IUserMapper um = () -> 1;
        System.out.println(um.insert());

        IUserDAO ud1 = (user) -> System.out.println(user.hashCode());
        ud1.insert(new User());

        //IUserDAO ud2 = () -> System.out.println(user.hashCode());
        //ud2.insert(new User());

        IOrderDAO od = o -> o.hashCode();
        System.out.println(od.order(new Order()));

        Supplier<String> ss = () -> "Hello";
        System.out.println(ss.get());

        Function<Integer, Integer> f = a -> {
            int s = 0, j = 0;
            for (; j <= a; ) {
                s += j++;
            }
            return s;
        };

        System.out.println(f.apply(100));

        Foo foo1 = () -> getInt();
        System.out.println(foo1.get());

        //Foo foo2 = () -> set();
        //Foo foo3 = () -> getStr();

        T tt1 = () -> getStr();
        tt1.t();
        T tt2 = () -> set(100);
        tt2.t();
        //T tt3 = () -> 100;
    }

    public static int getInt(){
        return 1;
    }

    public static int getStr(){
        return 1;
    }

    public static void set(int i){
        System.out.println(i);
    }
}

interface T{
    void t();
}

interface Foo{
    int get();
}

class User {

}

class Order {

}
