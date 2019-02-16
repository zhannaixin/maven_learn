package corejava.ch14;

/**
 * This program shows data corruption when multiple threads access a data structure.
 *
 * @author Cay Horstmann
 * @version 1.31 2015-06-21
 */
public class UnsynchBankTest {
    public static final int NACCOUNTS = 10;
    public static final double INITIAL_BALANCE = 1000;
    public static final double MAX_AMOUNT = 1000;
    public static final int DELAY = 10;

    public static void main(String[] args) {
        Bank bank = new Bank(NACCOUNTS, INITIAL_BALANCE);
        for (int i = NACCOUNTS - 1; i >= 0; i--) {
            int fromAccount = i;
            Runnable r = () -> {
                try {
                    while (true) {
                        int toAccount = (int) (bank.size() * Math.random());
                        double amount = MAX_AMOUNT * Math.random();
//                        System.out.printf(" %10.2f from %d to %d", amount, fromAccount, toAccount);
                        bank.transfer(fromAccount, toAccount, amount);
                        Thread.sleep((int) (DELAY * Math.random()));
                    }
                } catch (InterruptedException e) {
                }
            };
            Thread t = new Thread(r);
            t.start();
        }
    }
}