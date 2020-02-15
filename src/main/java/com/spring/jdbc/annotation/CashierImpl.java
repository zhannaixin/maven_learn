package com.spring.jdbc.annotation;

import com.spring.jdbc.BookShopService;
import com.spring.jdbc.Cashier;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service("cashier")
public class CashierImpl implements Cashier {

    @Autowired
    BookShopService bookShopService;

    @Transactional
    @Override
    public void checkout(String userName, String... isbns) {
        for(String isbn : isbns){
            bookShopService.purchase(userName, isbn);
        }
    }
}