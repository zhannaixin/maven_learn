package com.spring.beans.xml;

import java.util.Calendar;

public class CurrentTime {
    private Calendar calendar = Calendar.getInstance();
    @Override
    public String toString() {
        return "CurrentTime{" + calendar.getTime() + '}';
    }
}
