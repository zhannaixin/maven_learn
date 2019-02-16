package basic;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Objects;
import java.util.Optional;

import static java.lang.System.out;

public class TestObjects {

    /**
     * 不能生成对象
     * Caused by: java.lang.AssertionError: No java.util.Objects instances for you!
     * 	at java.base/java.util.Objects.<init>(Objects.java:58)
     *
     * 	throw new AssertionError("No java.util.Objects instances for you!");
     */
    @SuppressWarnings("ALL")
    public static void constructor(){
        ClassLoader cl = TestObjects.class.getClassLoader();
        try {
            Class<?> aClass = cl.loadClass("java.util.Objects");
            Constructor c = (aClass.getDeclaredConstructors())[0];
            c.setAccessible(true);
            Objects o = (Objects)(c.newInstance());
            out.println(o.toString());
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | InvocationTargetException e) {
            e.printStackTrace();
        }

    }


    /**
     *null与null比较总会返回true
     */
    public static void equals(){
        String s1 = "String";
        String s2 = "String";
        String s3 = null;
        BigDecimal b1 = new BigDecimal("0.00");
        BigDecimal b2 = new BigDecimal("0.00");
        BigDecimal b3 = null;

        out.println("Compare 2 Strings: " + Objects.equals(s1, s2));
        out.println("Compare 2 Numbers: " + Objects.equals(b1, b2));
        out.println("Compare 2 Nulls: " + Objects.equals(s3, b3));

        out.println(s1 instanceof String);
        out.println(s3 instanceof String);
//        out.println(s3 instanceof java.math.BigDecimal);

        ArrayList<String> al1 = new ArrayList<>();
        al1.add("1");
        al1.add("2");
        al1.add("3");

        ArrayList<String> al2 = new ArrayList<>();
        al2.add("1");
        al2.add("3");
        al2.add("2");

        HashSet<String> hs1 = new HashSet<>();
        hs1.add("1");
        hs1.add("2");
        hs1.add("3");
        HashSet<String> hs2 = new HashSet<>();
        hs2.add("2");
        hs2.add("1");
        hs2.add("3");

        out.println("Deep Compare 2 Strings: " + Objects.deepEquals(s1, s2));
        out.println("Deep Compare 1 String and 1 Number: " + Objects.deepEquals(s1, b1));
        out.println("Deep Compare 2 ArrayLists: " + Objects.deepEquals(al1, al2));
        out.println("Deep Compare 2 HashSet: " + Objects.deepEquals(hs1, hs2));

        out.println("HashCode ArrayList 1: " + Objects.hashCode(al1));
        out.println("HashCode ArrayList 2: " + Objects.hashCode(al2));
        out.println("HashCode null: " + Objects.hashCode(b3));

        out.println("Hash ArrayList 1: " + Objects.hash(al1));
        out.println("Hash ArrayList 2: " + Objects.hash(al2));
        out.println("Hash null: " + Objects.hash(b3));
        out.println("Hash null: " + Objects.hash(s3));
        out.println("Hash Number 1: " + Objects.hash(b1));
        out.println("Hash Number 2: " + Objects.hash(b2));
        out.println("Hash Number 2: " + b2.hashCode());

        out.println("null to String: " + b3);
        out.println("null to String: " + Objects.toString(b3, "BigDecimal Null"));


        out.println("BigDecimal null compares to String null : " + Objects.compare(s3,b3,null));

//        out.println("requireNonNull null: " + Objects.requireNonNull(s3, "不能使用空字符串"));
//        out.println("requireNonNull null: " + Objects.requireNonNull(s3, ()->null));
        out.println("requireNonNullElse null: " + Objects.requireNonNullElse(s3, "不能使用空字符串"));
        out.println("requireNonNullElseGet null: " + Objects.requireNonNullElseGet(s3, ()->""));
        out.println("isNull null: " + Objects.isNull(s3));
        out.println("nonNull null: " + Objects.nonNull(s3));


        out.println("checkIndex 1 3: " + Objects.checkIndex(1, 3));
//        out.println("checkIndex 4 3: " + Objects.checkIndex(4, 3)); //Index 4 out of bounds for length 3
        out.println("checkFromIndexSize 4 3 8: " + Objects.checkFromIndexSize(4, 3, 8));
    }



    public static void main(String[] args){
        constructor();
    }
}
