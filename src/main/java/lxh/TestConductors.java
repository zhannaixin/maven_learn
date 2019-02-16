package lxh;

import com.sun.jdi.ThreadGroupReference;

import java.nio.file.AtomicMoveNotSupportedException;
import java.util.concurrent.atomic.AtomicInteger;

class Ticket implements Runnable {
    AtomicInteger ticketNum = new AtomicInteger(10);

    @Override
    public void run() {
        while (this.ticketNum.get() > 0) {
            System.out.println(Thread.currentThread().getName() + " sales " + this.ticketNum.getAndDecrement());
        }
    }
}


public class TestConductors {
    public static void main(String[] args) {
        Ticket t = new Ticket();
        new Thread(t).start();
        new Thread(t).start();
        new Thread(t).start();
    }

}
