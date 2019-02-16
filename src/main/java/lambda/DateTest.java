package lambda;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Calendar;
import java.util.Date;

@SuppressWarnings("ALL")
public class DateTest {
    public static void main(String[] args) {
        Date d = new Date();
        System.out.println(d.toString());

        d.setYear(d.getYear() + 1);
        System.out.println(d.toString());

        LocalDate ld1 = LocalDate.now();
        System.out.println("ld1 = " + ld1);
        LocalDate ld2 = ld1.plusDays(1);
        System.out.println("ld1 = " + ld1);
        System.out.println("ld2 = " + ld2);

        BigDecimal b1 = new BigDecimal("100");
        System.out.println("b1 = " + b1);
        BigDecimal b2 = b1.add(new BigDecimal("200"));
        System.out.println("b1 = " + b1);
        System.out.println("b2 = " + b2);

        Calendar c = Calendar.getInstance();
        c.set(Calendar.MONTH, 1);
        System.out.println(c.get(Calendar.YEAR) + "-" + (c.get(Calendar.MONTH) + 1) + "-" + c.get(Calendar.DAY_OF_MONTH));

    }
}
