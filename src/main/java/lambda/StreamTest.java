package lambda;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;
import java.util.stream.Stream;

/**
 * 流的创建与测试
 * 1.可以使用limit限制输出个数
 * 2.fillter是延迟操作，在遇到终止操作（如forEach）之前是不会实际执行的
 * 3.在使用了一次终止操作后，流就结束了，不能再次使用
 */
public class StreamTest {

    /**
     * 通过数组创建
     */
    static void gen1() {
        String[] arr = {"a", "b", "1", "2"};
        Stream<String> stream = Stream.of(arr);
        stream.forEach(System.out::println);
    }

    /**
     * 通过集合创建
     */
    static void gen2() {
        List<String> lst = Arrays.asList("a", "b", "1", "2");
        Stream<String> stream = lst.stream();
        stream.forEach(System.out::println);
    }

    /**
     * 通过流创建
     */
    static void gen3() {
        Stream<String> stream = Stream.generate(() -> "Hello!");
        stream.limit(10).forEach(System.out::println);
    }

    /**
     * 通过流创建
     */
    static void gen4() {
        Stream<Integer> stream = Stream.iterate(1, x -> x + 1);
//        stream.limit(10).forEach(System.out::println); //如果不注释掉，下一行语句会报错，已经执行过终止操作了
//        stream.limit(20).filter(x -> x % 2 == 0).forEach(System.out::println);

//        int sum = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x %3 == 0).mapToInt(x -> x).sum();
//        System.out.println(sum);
//
//        int max = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x %3 == 0).max((x ,y) -> (x - y)).get();
//        System.out.println(max);
//
//        int min = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x %3 == 0).min((x ,y) -> (x - y)).get();
//        System.out.println(min);
//
//        long count = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x %3 == 0).count();
//        System.out.println(count);
//
//        double average = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x %3 == 0).mapToInt(x -> x).average().getAsDouble();
//        System.out.println(average);

//        Optional<Integer> any = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 3 == 0).findAny();
//        System.out.println(any.get());
//
//        Optional<Integer> first = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 3 == 0).findFirst();
//        System.out.println(first.get());
//        first = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 3 == 0).sorted((x, y) -> (y - x)).findFirst();
//        System.out.println(first.get());
//
//        boolean noneMatch = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 3 == 0).noneMatch(x -> x % 2 == 0);
//        System.out.println(noneMatch);
//
//        boolean allMatch = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 4 == 0).allMatch(x -> x % 2 == 0);
//        System.out.println(allMatch);
//
//        boolean anyMatch = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 4 == 0).anyMatch(x -> x % 5 == 0);
//        System.out.println(anyMatch);
//
//        List<Integer> integerList = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 4 == 0).collect(Collectors.toList());
//        System.out.println(integerList);
//
//        Object[] array = Stream.iterate(1, x -> x + 1).limit(20).filter(x -> x % 6 == 0).toArray();
//        System.out.println(Arrays.deepToString(array));

//        Stream.iterate(100, x -> x / 5).limit(20).distinct().forEach(System.out::println);
//        Stream.iterate(100, x -> x / 5).limit(10).distinct().sorted().skip(2).forEach(System.out::println);

//        String str = "11,22,33,44,55";
//        Stream.of(str.split(",")).mapToInt(Integer::valueOf).forEach(System.out::println);

//        String server = "tomcat,jetty,nginx,apache,jboss";
//        Stream.of(server.split(",")).map(Test::new).forEach(System.out::println);
//        Stream.of(server.split(",")).peek(System.out::println);

//        System.out.println(Stream.iterate(1, x -> x + 1).limit(20).peek(x ->
//                System.out.println(Thread.currentThread().getName())).max(Integer::compareTo));
//        System.out.println(Stream.iterate(1, x -> x + 1).limit(20).peek(x ->
//                System.out.println(Thread.currentThread().getName())).parallel().max(Integer::compareTo));
//        System.out.println(Stream.iterate(1, x -> x + 1).limit(20).peek(x ->
//                System.out.println(Thread.currentThread().getName())).parallel().sequential().max(Integer::compareTo));

//        ForkJoinPool forkJoinPool = new ForkJoinPool(5);
//        System.out.println(Stream.iterate(1, x -> x + 1).limit(20).peek(x ->
//                System.out.println(Thread.currentThread().getName())).parallel().max(Integer::compareTo));

        System.setProperty("java.util.concurrent.ForkJoinPool.common.parallelism", "2");
        System.out.println(Stream.iterate(1, x -> x + 5).limit(20).peek(x ->
                System.out.println(Thread.currentThread().getName())).parallel().max(Integer::compareTo));
    }

    /**
     * 通其他方式创建
     */
    static void gen5() throws IOException {
        IntStream stream = new String("123").chars();
        stream.forEach(System.out::println);

        Stream<String> fStream = Files.lines(Paths.get("E:\\IdeaProjects\\learn\\src\\lambda\\StreamTest.java"));
        fStream.forEach(System.out::println);
    }

    public static void main(String[] args) throws IOException {
        StreamTest.gen5();
        StreamTest.gen4();
        StreamTest.gen3();
        StreamTest.gen2();
        StreamTest.gen1();
    }
}

class Test {
    String name;

    public Test(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "Test{" +
                "name='" + name + '\'' +
                '}';
    }
}
