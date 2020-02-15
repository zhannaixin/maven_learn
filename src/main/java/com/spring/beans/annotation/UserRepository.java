package com.spring.beans.annotation;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository("repository")
public class UserRepository implements com.spring.beans.Repository {

    @Autowired(required = false)
    private TestObject testObject;

    @Override
    public void save() {
        System.out.println("UerRepositoryImpl save...");
        System.out.println(testObject);
    }
}
