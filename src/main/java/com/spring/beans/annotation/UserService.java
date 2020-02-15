package com.spring.beans.annotation;

import com.spring.beans.Repository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

@Service("service")
public class UserService implements com.spring.beans.Service {

    Repository repository;

    @Autowired  //可以省略set方法，直接放在域上
//    @Qualifier("userJdbcRepository")
    public void setUserRepository(@Qualifier("jdbcRepository") Repository repository) {
        this.repository = repository;
    }

    public void add() {
        System.out.println("UserService add...");
        repository.save();
    }
}
