package com.spring.beans.annotation;


import org.springframework.stereotype.Repository;

@Repository
public class JdbcRepository implements com.spring.beans.Repository {
    @Override
    public void save() {
        System.out.println("JdbcRepository save...");
    }
}
