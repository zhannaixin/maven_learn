package lambda;

import java.util.ArrayList;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;


/**
 * 方法的引用
 * <p>
 * 引用类型  引用语法              一般Lambda表达式语法
 * 静态方法  类名::staticMethod   (args) -> 类名.staticMethod(args)         Supplier<String> s1 = MethodRefTest::put;
 * 实例方法  实例::instMethod     (args) -> 实例.instMethod(args)           Consumer<String> c2 = System.out::println;
 * 对象方法  类名::instMethod     (inst, args) -> inst.instMethod(args)    Function<String, String> f2 = String::toUpperCase;//抽象方法至少要有一个输入参数
 * 构造方法  类名::new            (args) -> new 类名(args)                  Function<byte[], String> f4 = String::new;//输入参数类型必须与构造方法参数一致
 * </p>
 */
public class MethodRefTest {

    private ArrayList<String> as;

    private static Consumer<String> c1 = str -> System.out.println(str);

    private static Function<String, String> f1 = str -> str.toUpperCase();

    /**
     * 静态方法引用
     */
    private static Supplier<String> s1 = MethodRefTest::put;

    /**
     * 实例方法引用
     */
    private static Consumer<String> c2 = System.out::println;

    /**
     * 对象方法引用
     */
    private static Function<String, String> f2 = String::toUpperCase;
    private static Function<String, Integer> f3 = String::hashCode;

    /**
     * 构造方法引用
     */
    private static Function<byte[], String> f4 = String::new;
    private static Supplier<MethodRefTest> s2 = MethodRefTest::new;

    public MethodRefTest(){
        System.out.println("调用了构造方法！");
    }


    public static String put() {
        System.out.println("put method invokes.");
        return "PUT";
    }

    public static void main(String[] args) {
        System.out.println(f1.apply("Hello"));
        c1.accept("world");

        System.out.println(f2.apply("String::toUpperCase"));
        System.out.println(f3.apply("String::toUpperCase"));
        c2.accept("Hello World!");
        System.out.println(s1.get());

        System.out.println(f4.apply("构造方法引用".getBytes()));
        s2.get();

    }
}
