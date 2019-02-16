package basic;

import java.util.EnumMap;
import java.util.EnumSet;
import java.util.HashSet;

import static java.lang.System.out;

/**
 * 比较两个枚举对象时，不需要调用equal方法，直接使用==即可
 * <p>
 * values()方法是编译器插入到enum定义中的static方法，所以，当将enum实例向上转型为父类Enum时，values()方法就不可用了。
 * Class类中提供了getEnumConstants()方法，可以取得所有enum实例。
 * <p>
 * 所有enum都继承自Enum类，所有不能再继承别的类了
 * <p>
 * 无法从enum继承子类，如果需要扩展enum中的元素，在一个接口内部，创建实现该接口的枚举，以此将元素进行分组，达到将枚举元素进行分组。
 */


enum Color {RED, GREEN, BLUE}

/**
 * 自定义枚举
 */
enum Weekday {
    Mon("Monday"), Tue("Tuesday"), Wed("Wednesday"),
    Thu("Thursday"), Fri("Friday"), Sat("Saturday"), Sun("Sunday");

    private final String day;

    Weekday(String _day) {
        this.day = _day;
    }

    public static void printDay(int i) {
        switch (i) {
            case 1:
                out.println(Weekday.Mon);
                break;
            case 2:
                out.println(Weekday.Tue);
                break;
            case 3:
                out.println(Weekday.Wed);
                break;
            case 4:
                out.println(Weekday.Thu);
                break;
            case 5:
                out.println(Weekday.Fri);
                break;
            case 6:
                out.println(Weekday.Sat);
                break;
            case 7:
                out.println(Weekday.Sun);
                break;
            default:
                out.println("Wrong number!");
        }
    }

    public String getDay() {
        return day;
    }
}

/**
 * 自定义枚举
 */
enum E {
    A(1, "First"),
    B(2, "Second");

    int code;

    String desc;

    public int getCode() {
        return code;
    }

    public String getDesc() {
        return desc;
    }

    E(int code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public String toString() {
        return code + ":" + desc + "\t" + super.ordinal();
    }

}

/**
 * 用接口管理枚举及枚举实现接口
 * 如何使用？？？
 */
interface IE {
    enum Coffee implements IE {
        BLACK_COFFEE, DECAF_COFFEE, LATTE, CAPPUCCINO
    }

    enum Dessert implements IE {
        FRUIT, CAKE, GELATO
    }
}

enum JES {
    A001, A002, A003, A004, A005, A006, A007, A008, A009, A010, A011, A012, A013, A014, A015, A016,
    A017, A018, A019, A020, A021, A022, A023, A024, A025, A026, A027, A028, A029, A030, A031, A032,
    A033, A034, A035, A036, A037, A038, A039, A040, A041, A042, A043, A044, A045, A046, A047, A048,
    A049, A050, A051, A052, A053, A054, A055, A056, A057, A058, A059, A060, A061, A062, A063, A064,
    A065, A066, A067, A068, A069, A070, A071, A072, A073, A074, A075, A076, A077, A078, A079, A080,
    A081, A082, A083, A084, A085, A086, A087, A088, A089, A090, A091, A092, A093, A094, A095, A096,
    A097, A098, A099, A100, A101, A102, A103, A104, A105, A106, A107, A108, A109, A110, A111, A112,
    A113, A114, A115, A116, A117, A118, A119, A120, A121, A122, A123, A124, A125, A126, A127, A128
}

public class TestEnum implements IE {

    private Coffee iec = null;
    private Dessert ied = null;

    private void setIec(Coffee _iec) {
        iec = _iec;
    }

    private void setIed(Dessert _ied) {
        ied = _ied;
    }

    private static void testIE() {
        out.println("======测试IE=====================================");
        TestEnum te = new TestEnum();
        te.setIec(Coffee.BLACK_COFFEE);
        te.setIec(Coffee.DECAF_COFFEE);
        te.setIec(Coffee.LATTE);
        te.setIec(Coffee.CAPPUCCINO);
        out.println(te.iec);

        te.setIed(Dessert.CAKE);
        te.setIed(Dessert.FRUIT);
        te.setIed(Dessert.GELATO);
        out.println(te.ied);
    }

    private static void testColor() {
        out.println("======测试Color==================================");
        for (Color c : Color.values()) {
            out.println(c.getClass().getName()
                    + ": " + c
                    + "\t" + c.ordinal()
                    + "\t" + c.name()
                    + "\t" + Enum.valueOf(Color.class, c.toString())
            );
        }
    }

    private static void testWeekday() {
        out.println("======测试Weekday================================");
        Weekday.printDay(2);
        out.println(Weekday.Sun);
        out.println(Weekday.Sun.getDay());
    }

    private static void testE() {
        out.println("======测试E======================================");
        long ms = System.currentTimeMillis();
        out.println(E.B);
        E e = (ms % 2 == 0) ? E.A : E.B;
        switch (e) {
            case A:
                out.println(e.getCode());
                break;
            case B:
                out.println(e.getDesc());
                break;
            default:
                out.println(e);
        }
    }


    /**
     * 测试EnumMap、EnumSet
     */
    private static void testCollection() {
        out.println("======测试EnumMap、values()=============================");
        EnumMap<Weekday, String> emw = new EnumMap<>(Weekday.class);
        emw.put(Weekday.Mon, "星期一");
        emw.put(Weekday.Tue, "星期二");
        emw.put(Weekday.Wed, "星期三");
        emw.put(Weekday.Thu, "星期四");
        emw.put(Weekday.Fri, "星期五");
        emw.put(Weekday.Sat, "星期六");
        emw.put(Weekday.Sun, "星期七");

        for (Weekday w : Weekday.values()) {
            out.println("[key=" + w.name() + ", value=" + emw.get(w) + "]");
        }

        out.println("======测试EnumSet、allOf================================");
        EnumMap<Color, String> emc = new EnumMap<>(Color.class);
        emc.put(Color.RED, "红色");
        emc.put(Color.GREEN, "绿色");
//        emc.put(Color.BLUE, "蓝色");
        for (Color c : EnumSet.allOf(Color.class)) {
            out.println("[key=" + c.name() + ", value=" + emc.get(c) + "]");
        }

        out.println("======单独测试EnumSet==================================");
        EnumSet<Color> es = EnumSet.of(Color.BLUE, Color.RED);
        out.println("EnumSet.of--初始化2个元素的集合大小：" + es.size() + "，内容：" + es); //2，[RED, BLUE]

        es = EnumSet.noneOf(Color.class);
        out.println("EnumSet.noneOf--初始化空集合大小：" + es.size() + "，内容：" + es); //0，[]

        es.add(Color.BLUE);
        es = EnumSet.copyOf(es);
        out.println("EnumSet.copyOf(EnumSet<E>)--拷贝1个元素集合大小：" + es.size() + "，内容：" + es); //1，[BLUE]

        HashSet<Color> hs = new HashSet<>();
        hs.add(Color.BLUE);
        es = EnumSet.copyOf(hs);
        out.println("EnumSet.copyOf(Collection<E>)--拷贝1个元素集合大小：" + es.size() + "，内容：" + es); //1，[BLUE]

        es = EnumSet.complementOf(es);
        out.println("EnumSet.complementOf(EnumSet<E>)--补集大小：" + es.size() + "，内容：" + es); //2，[RED, GREEN]

        es = EnumSet.range(Color.RED, Color.GREEN);
        out.println("EnumSet.range--集合大小：" + es.size() + "，内容：" + es); //2，[RED, GREEN]

        es = es.clone();
        out.println("EnumSet-clone--集合大小：" + es.size() + "，内容：" + es); //2，[RED, GREEN]
        out.println("EnumSet-clone==--集合大小：" + (es == es.clone())); //2，[RED, GREEN]

        out.println("EnumSet-addAll--结果：" + es.addAll(es.clone())); //false
        out.println("EnumSet-addAll--结果：" + es.addAll(EnumSet.of(Color.BLUE))); //true

        out.println("EnumSet-removeAll--结果：" + es.removeAll(EnumSet.of(Color.BLUE))); //true
        out.println("EnumSet-removeAll--结果：" + es.removeAll(EnumSet.of(Color.BLUE))); //false

        out.println("EnumSet-containsAll--结果：" + es.containsAll(EnumSet.of(Color.RED))); //true
        out.println("EnumSet-containsAll--结果：" + es.containsAll(EnumSet.of(Color.BLUE))); //false

        out.println("EnumSet-retainAll--结果：" + es.retainAll(EnumSet.of(Color.BLUE, Color.RED))); //true
        out.println("EnumSet-retainAll--结果：" + es);//[RED]

        out.println("EnumSet-retainAll--结果：" + es.retainAll(EnumSet.of(Color.RED))); //false
        out.println("EnumSet-retainAll--结果：" + es);//[RED]

        es.clear();
        out.println("EnumSet-clear--结果：" + es); //[]
        //即使类型不一样，空的比较结果也会返回true
        out.println("EnumSet-equals--结果：" + es.equals(EnumSet.noneOf(Weekday.class)));//true

    }

    private static void testJumboEnumSet(){
        EnumSet jes = EnumSet.range(JES.A067, JES.A097);
        out.println("EnumSet.range--集合大小：" + jes.size() + "，内容：" + jes); //2，[RED, GREEN]
    }

    private static void testOthers() {
        out.println(Coffee.BLACK_COFFEE);
        out.println(Dessert.GELATO.ordinal());
        out.println("======测试compareTo=====================================");
        out.println(Dessert.GELATO.compareTo(Dessert.CAKE));
        out.println("======测试class=========================================");
        out.println(Coffee.BLACK_COFFEE.getClass());
        out.println(Coffee.BLACK_COFFEE.getClass().getSuperclass());
        out.println(Coffee.BLACK_COFFEE.getDeclaringClass());
        out.println("======测试valueOf=========================================");
        out.println(Enum.valueOf(Color.class, "BLUE").ordinal());
        out.println("======测试hashCode=========================================");
        out.println(Enum.valueOf(Color.class, "BLUE").hashCode());
    }

    private static void testALL() {
        testColor();
        testCollection();
        testWeekday();
        testIE();
        testOthers();
        testE();

    }

    public static void main(String[] args) {
        out.println("  ".trim());
        out.println("  ".trim());
        //testALL();
        testJumboEnumSet();
    }

}
