package com.spring.beans.xml;

public abstract class LookUpBean {
    private CurrentTime currentTime;
    public CurrentTime getCurrentTime() {
        return currentTime;
    }
    public void setCurrentTime(CurrentTime currentTime) {
        this.currentTime = currentTime;
    }
    public abstract CurrentTime createCurrentTime();
}