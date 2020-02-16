package com.spring.hibernate.service.impl;

import com.spring.jdbc.BookShopService;
import com.spring.jdbc.Cashier;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CashierHibernateImpl implements Cashier {

    @Autowired
    BookShopService bookShopServiceHibernateImpl;

    @Override
    public void checkout(String userName, String... isbns) {
        for (String isbn : isbns) {
            bookShopServiceHibernateImpl.purchase(userName, isbn);
        }
    }
}
