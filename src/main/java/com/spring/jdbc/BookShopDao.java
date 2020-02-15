package com.spring.jdbc;

import java.math.BigDecimal;

public interface BookShopDao {
    BigDecimal findBookPriceByIsbn(String isbn);
    BigDecimal getUserBalance(String userName);
    void updateBookStock(String isbn);
    int getBookStock(String isbn);
    void updateUserAccount(String userName, BigDecimal price);
}
