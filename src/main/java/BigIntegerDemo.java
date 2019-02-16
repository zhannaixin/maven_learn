import java.math.BigInteger;
import java.util.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import static java.lang.System.out;

/**
 * Created by Administrator on 2014/4/17.
 */
public class BigIntegerDemo {
    /**
     * Demonstrate BigInteger.byteValueExact().
     */
    private static void demonstrateBigIntegerByteValueExact() {
        final BigInteger byteMax = new BigInteger(String.valueOf(Byte.MAX_VALUE));
        out.println("Byte Max: " + byteMax.byteValue());
        out.println("Byte Max: " + byteMax.byteValueExact());
        final BigInteger bytePlus = byteMax.add(BigInteger.ONE);
        out.println("Byte Max + 1: " + bytePlus.byteValue());
        out.println("Byte Max + 1: " + bytePlus.byteValueExact());
    }


    /**
     * Demonstrate BigInteger.shortValueExact().
     */
    private static void demonstrateBigIntegerShortValueExact() {
        final BigInteger shortMax = new BigInteger(String.valueOf(Short.MAX_VALUE));
        out.println("Short Max: " + shortMax.shortValue());
        out.println("Short Max: " + shortMax.shortValueExact());
        final BigInteger shortPlus = shortMax.add(BigInteger.ONE);
        out.println("Short Max + 1: " + shortPlus.shortValue());
        out.println("Short Max + 1: " + shortPlus.shortValueExact());
    }


    /**
     * Demonstrate BigInteger.intValueExact().
     */
    private static void demonstrateBigIntegerIntValueExact() {
        final BigInteger intMax = new BigInteger(String.valueOf(Integer.MAX_VALUE));
        out.println("Int Max: " + intMax.intValue());
        out.println("Int Max: " + intMax.intValueExact());
        final BigInteger intPlus = intMax.add(BigInteger.ONE);
        out.println("Int Max + 1: " + intPlus.intValue());
        out.println("Int Max + 1: " + intPlus.intValueExact());
    }


    /**
     * Demonstrate BigInteger.longValueExact().
     */
    private static void demonstrateBigIntegerLongValueExact() {
        final BigInteger longMax = new BigInteger(String.valueOf(Long.MAX_VALUE));
        out.println("Long Max: " + longMax.longValue());
        out.println("Long Max: " + longMax.longValueExact());
        final BigInteger longPlus = longMax.add(BigInteger.ONE);
        out.println("Long Max + 1: " + longPlus.longValue());
        out.println("Long Max + 1: " + longPlus.longValueExact());

    }


    /**
     * Demonstrate BigInteger's four new methods added with JDK 8.
     *
     * @param arguments Command line arguments.
     */
    public static void main(final String[] arguments) {
        optionalTest();
    }

    public static void optionalTest() {
        Optional<String> stringOrNot = Optional.of("123");

        // This String reference will never be null
        String alwaysAString = stringOrNot.orElse("");

        // This Integer reference will be wrapped again
        Optional<Integer> integerOrNot = stringOrNot.map(Integer::parseInt);

        // This int reference will never be null
        int alwaysAnInt = stringOrNot.map(s -> Integer.parseInt(s)).orElse(0);

        System.out.println(alwaysAString);
        System.out.println(integerOrNot);
        System.out.println(alwaysAnInt);
        Arrays.asList(1, 2, 3).stream().findAny().ifPresent(System.out::println);

        // Stream and Optional
         Arrays.asList(1, 2, 3)
                        .stream()
                        .filter(i -> i % 2 == 1)
                        .findAny()
                        .ifPresent(System.out::println);

        // IntStream and OptionalInt
         Arrays.stream(new int[] {1, 2, 3})
                        .filter(i -> i % 2 == 1)
                        .findAny()
                        .ifPresent(System.out::println);
    }

    public static void t3() {
        Runnable runnable = new Runnable() {
            public void run() {
                // task to run goes here
                System.out.println("Hello !!");
            }
        };

        ScheduledExecutorService service = Executors.newSingleThreadScheduledExecutor();
        service.scheduleAtFixedRate(runnable, 0, 1, TimeUnit.SECONDS);
    }

    public static void t2() {
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                // task to run goes here
                System.out.println("Hello !!!");
            }
        };

        Timer timer = new Timer();
        long delay = 0;
        long intevalPeriod = 1 * 1000;

        // schedules the task to be run in an interval
        timer.scheduleAtFixedRate(task, delay, intevalPeriod);
    }

    public static void t1() {
        final long timeInterval = 1000;
        Runnable runnable = new Runnable() {

            public void run() {
                while (true) {
                    // ------- code for task to run
                    System.out.println("Hello !!");
                    // ------- ends here
                    try {
                        Thread.sleep(timeInterval);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        };

        Thread thread = new Thread(runnable);
        thread.start();
    }

    public static void run() {
        System.setErr(out); // exception stack traces to go to standard output
        try {
            demonstrateBigIntegerByteValueExact();
        } catch (Exception exception) {
            exception.printStackTrace();
        }


        try {
            demonstrateBigIntegerShortValueExact();
        } catch (Exception exception) {
            exception.printStackTrace();
        }


        try {
            demonstrateBigIntegerIntValueExact();
        } catch (Exception exception) {
            exception.printStackTrace();
        }


        try {
            demonstrateBigIntegerLongValueExact();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

    }

}

interface HasName {
    class Extensions {
        private static final WeakHashMap<HasName, String> map = new WeakHashMap<>();
    }

    default void setName(String name) {
        Extensions.map.put(this, name);
    }

    default String getName() {
        return Extensions.map.get(this);
    }
}