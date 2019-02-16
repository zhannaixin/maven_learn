package lambda;

/**
 * 函数式接口：只有一个抽象方法的接口
 * 可以使用FunctionalInterface明确标识，并校验
 *
 * 常用函数式接口：
 * java.util.Comparator<T>
 * java.util.concurrent.Callable<V>
 * java.lang.Runnable
 *
 * java.util.function.Supplier<T> T get();                   代表生产者，输出
 * java.util.function.Consumer<T> void accept(T t);          代表消费者，输入
 * java.util.function.BConsumer<T, U> void accept(T t, U u); 代表消费者，2个输入
 * java.util.function.Function<T, R> R apply(T t);           代表转换，T输入，R输出
 *   有默认方法，需要研读
 * java.util.function.UnaryOperator<T> extends Function<T, T> 相同的输入、输出
 * java.util.function.BiFunction<T, U, R> R apply(T t, U u);  代表转换，T、U输入，R输出
 * java.util.function.BinaryOperator<T> extends BiFunction<T,T,T>  相同的输入、输出
 *
 * Lambda表达式是对象，是一个函数式接口的实例
 * 语法：
 *    Lambda参数 -> Lambda实现体
 *    args -> expr
 *    (Object... args) -> {expr...}
 *    参数个数需要与函数式接口中抽象方法一致
 *    只有一个参数时，可以省略小括号，只有一条实现语句时，可以省略大括号及return
 * 示例：
 *    Runnable r = () -> System.out.println("Hello");
 *    () -> {}                       //没有参数，没有返回值
 *    () -> {System.out.println(1);} //没有参数，没有返回值
 *    () -> System.out.println(1);   //没有参数，没有返回值
 *    () -> {return 100;}            //没有参数，有返回值
 *    () -> 100                      //没有参数，有返回值
 *    () -> null                     //没有参数，有返回值
 *    (int x) -> {return x + 1;}     //单个参数，有返回值
 *    (int x) -> return x + 1;       //单个参数，有返回值
 *    (x) -> x + 1                   //单个参数，有返回值（多个参数时，不指定参数类型，则不能省略小括号）
 *    x -> x + 1                     //单个参数，有返回值（不指定参数类型）
 * 注意事项：
 *    (x, int y) -> x + y                     //错误，参数类型要么全部省略，要么全部不省略
 *    (x, final y) -> x + y                   //错误，不能在参数上使用final描述符
 *    Object obj = () -> "Hello"              //错误，不能将Lambda表达式赋值给非函数式接口变量
 *    Object obj = (Supplier<?>)() -> "Hello" //可以强制类型转换赋值
 *    Lambda表达式不允许使用throws语句来声明它可能抛出的异常
 */
@FunctionalInterface
public interface IUserMapper {
    int insert();

    //默认实现方法不算
    default int update() {

        return 1;
    }

    //静态方法不算
    static int select() {
        return 2;
    }

    //object默认方法不算
    //public int hashcode();


}
