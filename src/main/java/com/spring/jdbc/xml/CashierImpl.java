package com.spring.jdbc.xml;

import com.spring.jdbc.BookShopService;
import com.spring.jdbc.Cashier;

public class CashierImpl implements Cashier {

    BookShopService bookShopService;

    public BookShopService getBookShopService() {
        return bookShopService;
    }

    public void setBookShopService(BookShopService bookShopService) {
        this.bookShopService = bookShopService;
    }

    @Override
    public void checkout(String userName, String... isbns) {
        for(String isbn : isbns){
            bookShopService.purchase(userName, isbn);
        }
    }
}

