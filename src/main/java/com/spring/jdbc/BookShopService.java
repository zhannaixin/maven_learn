package com.spring.jdbc;

public interface BookShopService {
    /** 购买一本书 */
    void purchase(String userName, String isbn);
}
