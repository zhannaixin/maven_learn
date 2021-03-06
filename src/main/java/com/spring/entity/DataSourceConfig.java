package com.spring.entity;

import java.util.Properties;

public class DataSourceConfig {

    private Properties properties;

    public Properties getProperties() {
        return properties;
    }

    public void setProperties(Properties properties) {
        this.properties = properties;
    }

    @Override
    public String toString() {
        return "DataSourceConfig{" +
                "properties=" + properties +
                '}';
    }
}
