package com.spring.jdbc.xml;

import com.spring.jdbc.BookShopDao;
import com.spring.jdbc.BookShopService;

import java.math.BigDecimal;

public class BookShopServiceImpl implements BookShopService {

    private BookShopDao bookShopDao;

    public BookShopDao getBookShopDao() {
        return bookShopDao;
    }

    public void setBookShopDao(BookShopDao bookShopDao) {
        this.bookShopDao = bookShopDao;
    }

    @Override
    public void purchase(String userName, String isbn) {

//        try {
//            Thread.sleep(5000);
//        } catch (InterruptedException e) {
//            e.printStackTrace();
//        }

        BigDecimal price = bookShopDao.findBookPriceByIsbn(isbn);

        bookShopDao.updateBookStock(isbn);

        bookShopDao.updateUserAccount(userName, price);
    }
}

