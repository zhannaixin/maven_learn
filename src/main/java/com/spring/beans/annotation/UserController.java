package com.spring.beans.annotation;

import com.spring.beans.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

@Controller("controller")
public class UserController implements com.spring.beans.Controller {

    @Autowired
    private Service service;

    public void execute(){
        System.out.println("UserController execute...");
        service.add();
    }
}
