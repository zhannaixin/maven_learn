package basic;

import static java.lang.System.out;

public class Unicode {
    /**
     * 左移位 <<          乘以2
     * 有符号右移 >>       除以2
     * 无符号右移 >>>      忽略符号位，空位一律补0
     *
     * 1.如果移动的位数是负数（A），则等同于移动（L - abs(A)）位。对于int，L=32，对于long，L=64。
     * 2.如果移动的位数是大于该数字最大位数（A），则等同于移动（A%L）位。对于int，L=32，对于long，L=64。
     *   如果结果是负数，还要应用规则1。
     *
     * shift
     */
    private static void bites() {
        out.println("2 << 3 = " + Integer.toHexString((2 << 3)));    // 00000000000000000000000000000010 -> 00000000000000000000000000010000 16
        out.println("-2 >> 3 = " + Integer.toHexString((-2 >> 3)));  // 11111111111111111111111111111110 -> 11111111111111111111111111111111 -1
        out.println("-2 >>> 3 = " + Integer.toHexString((-2 >>> 3)));// 11111111111111111111111111111110 -> 11111111111111111111111111111 536870911

        out.println("~1 = \t" + Integer.toHexString(~1));
        out.println("-1 = \t" + Integer.toHexString(-1));
        out.println("-1 << 12 = \t" + Integer.toHexString((-1 << 12)));
        out.println("-1 << -12 = \t" + Integer.toHexString((-1 << -12)));
        out.println("-1 << (32 - 12) = \t" + Integer.toHexString((-1 << (32 - 12))));
        out.println("-1 >> 12 = \t" + Integer.toHexString((-1 >> 12)));
        out.println("-1 >> -12 = \t" + Integer.toHexString((-1 >> -12)));
        out.println("-1 >> (32 - 12) = \t" + Integer.toHexString((-1 >> (32 - 12))));
        out.println("-1 >>> 12 = \t" + Integer.toHexString((-1 >>> 12)));
        out.println("-1 >>> -12 = \t" + Integer.toHexString((-1 >>> -12)));
        out.println("-1 >>> (32 - 12) = \t" + Integer.toHexString((-1 >>> (32 - 12))));

        out.println("12 = \t" + Integer.toHexString((12)));
        out.println("-12 = \t" + Integer.toHexString((-12)));

        out.println(Long.numberOfTrailingZeros(4));


        out.println("-1L << 67 = \t" + Long.toHexString((-1L << 67)));
        out.println("-1L << -67 = \t" + Long.toHexString((-1L << -67)));
    }

    /**
     * Unicode序列是在编译早期被编译器解释的，所以\u000a 不能使用在print中，會被提前替換成換行，导致错误
     * 可以使用的Unicode字符范围： \u0000 ~ \u00ff
     */
    private static void unicode() {
        /*out.println("\\u000a = " + '\u000a') ;*/
    }

    public static void main(String[] args) {
        bites();
        unicode();
    }

}
