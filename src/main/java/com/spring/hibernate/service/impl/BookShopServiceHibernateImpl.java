package com.spring.hibernate.service.impl;

import com.spring.jdbc.BookShopDao;
import com.spring.jdbc.BookShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class BookShopServiceHibernateImpl implements BookShopService {

    @Autowired
    BookShopDao bookShopDaoHibernateImpl;

    @Override
    public void purchase(String userName, String isbn) {
        BigDecimal price = bookShopDaoHibernateImpl.findBookPriceByIsbn(isbn);
        bookShopDaoHibernateImpl.updateBookStock(isbn);
        bookShopDaoHibernateImpl.updateUserAccount(userName, price);
    }
}
