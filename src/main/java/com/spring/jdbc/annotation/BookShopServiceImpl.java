package com.spring.jdbc.annotation;

import com.spring.jdbc.BookShopDao;
import com.spring.jdbc.BookShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service("bookShopService")
public class BookShopServiceImpl implements BookShopService {

    @Autowired
    private BookShopDao bookShopDao;

    //1.同一个类内部使用同一个事务，不同类之间会有事务传播行为
    //  默认使用调用方法的事务Propagation.REQUIRED
    //2.隔离级别
    //3.回滚一般使用默认设置
    //  忽略某些异常可以使用noRollbackFor = {RuntimeException.class}
    //4.readOly(不加锁)事务是否只读
    //5.超时设置，强制回滚前，最多执行时间，单位秒
    @Transactional(propagation = Propagation.REQUIRES_NEW,
            isolation = Isolation.READ_COMMITTED,
            readOnly = false,
            timeout = 3)
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
