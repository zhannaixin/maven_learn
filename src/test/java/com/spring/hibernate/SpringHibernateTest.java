package com.spring.hibernate;

import com.spring.jdbc.BookShopService;
import com.spring.jdbc.Cashier;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import javax.sql.DataSource;
import java.sql.SQLException;

public class SpringHibernateTest {
    ApplicationContext ctx = new ClassPathXmlApplicationContext("config/applicationContext.xml");

    @Test
    public void testDataSource() throws SQLException {
        DataSource dataSource = ctx.getBean("dataSourceMariaDB", DataSource.class);
        System.out.println(dataSource.getConnection());
    }

    @Test
    public void testBookShopService(){
        BookShopService bookShopService = ctx.getBean("bookShopServiceHibernateImpl", BookShopService.class);
        bookShopService.purchase("AA", "1001");
    }

    @Test
    public void testCashier(){
        Cashier cashier = ctx.getBean("cashierHibernateImpl", Cashier.class);
        cashier.checkout("AA", "1001", "1002");
    }
}
