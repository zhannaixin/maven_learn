package lxh;

import java.awt.*;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

class Conductor implements Callable<String>{
    AtomicInteger ticketNum = new AtomicInteger(10);

    @Override
    public String call() throws Exception {
        while (this.ticketNum.get() > 0) {
            System.out.println(Thread.currentThread().getName() + " sales " + this.ticketNum.getAndDecrement());
        }

        return "All ticket is sold!";
    }
}

public class TestCallable {
    public static void main(String[] args) throws Exception {
        Callable c = new Conductor();
        FutureTask<String> ft = new FutureTask<>(c);
        Thread t = new Thread(ft);
        t.start();
        System.out.println("Now: " + ft.get(5, TimeUnit.SECONDS));
    }
}
