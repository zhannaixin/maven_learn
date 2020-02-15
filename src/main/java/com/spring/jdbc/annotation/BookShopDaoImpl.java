package com.spring.jdbc.annotation;

import com.spring.jdbc.BookShopDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;

@Repository("bookShopDao")
public class BookShopDaoImpl implements BookShopDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public BigDecimal findBookPriceByIsbn(String isbn) {
        String sql = "SELECT PRICE FROM BOOK WHERE ISBN = ?";
        return jdbcTemplate.queryForObject(sql, BigDecimal.class, isbn);
    }

    @Override
    public BigDecimal getUserBalance(String userName) {
        String sql = "SELECT BALANCE FROM ACCOUNT WHERE USER_NAME = ?";
        return jdbcTemplate.queryForObject(sql, BigDecimal.class, userName);
    }

    @Override
    public void updateBookStock(String isbn) {
        String sql = "UPDATE BOOK_STOCK SET STOCK = STOCK - 1 WHERE ISBN = ?";
        jdbcTemplate.update(sql, isbn);
    }

    @Override
    public int getBookStock(String isbn) {

//        int stock = getBookStock(isbn);
//        if(stock < 1){
//            System.err.println("库存不足！");
//            throw new RuntimeException("库存不足！");
//        }

        String sql = "SELECT STOCK FROM BOOK_STOCK WHERE ISBN = ?";
        return jdbcTemplate.queryForObject(sql, Integer.class, isbn);
    }

    @Override
    public void updateUserAccount(String userName, BigDecimal price) {
        BigDecimal balance = getUserBalance(userName);

        if(balance.compareTo(BigDecimal.ZERO) <= 0 || balance.compareTo(price) < 0){
            System.err.println("余额不足！");
            throw new RuntimeException("余额不足！");
        }

        String sql = "UPDATE ACCOUNT SET BALANCE = BALANCE - ? WHERE USER_NAME = ?";
        jdbcTemplate.update(sql, price, userName);
    }
}
