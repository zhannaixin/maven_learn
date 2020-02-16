package com.spring.hibernate.dao.impl;

import com.spring.entity.Account;
import com.spring.entity.Book;
import com.spring.jdbc.BookShopDao;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.query.Query;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;

@Repository
public class BookShopDaoHibernateImpl implements BookShopDao {

    @Autowired
    private SessionFactory sessionFactory;

    //在方法开始之前：获取session并与当前线程绑定，然后开启事务。
    //在方法正常结束，提交，解除绑定，抛出异常则回滚失误
    private Session getSession(){
        return sessionFactory.getCurrentSession();
    }

    @Override
    public BigDecimal findBookPriceByIsbn(String isbn) {
        return getBook(isbn).getPrice();
    }

    @Override
    public int getBookStock(String isbn) {
        return getBook(isbn).getStock();
    }

    public Book getBook(String isbn){
        String sql = "FROM Book b WHERE b.isbn = ?1";
        Query<Book> query = getSession().createQuery(sql).setParameter(1, isbn);
        return query.uniqueResult();
    }


    @Override
    public void updateBookStock(String isbn) {
        Book book = getBook(isbn);
        if(book.getStock() <= 0){
            throw new RuntimeException("库存不足！");
        }

        book.setStock(book.getStock() - 1);

    }

    public Account getAccount(String userName){
        String sql = "FROM Account a WHERE a.userName = ?1";
        Query<Account> query = getSession().createQuery(sql).setParameter(1, userName);
        return (Account) (query.uniqueResult());
    }

    @Override
    public BigDecimal getUserBalance(String userName) {
        return getAccount(userName).getBalance();
    }

    @Override
    public void updateUserAccount(String userName, BigDecimal price) {
        if(price == null){
            throw new RuntimeException("错误的金额！");
        }

        Account account = getAccount(userName);
        if(account == null){
            throw new RuntimeException("用户不存在！");
        }

        if(account.getBalance() == null || account.getBalance().compareTo(price) < 0){
            throw new RuntimeException("余额不足！");
        }

        account.setBalance(account.getBalance().subtract(price));
    }
}
