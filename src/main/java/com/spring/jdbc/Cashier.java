package com.spring.jdbc;

public interface Cashier {
    /** 购买多本书 */
    void checkout(String userName, String... isbns);
}
