package com.dbquest.dbq.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

import org.apache.commons.configuration.PropertiesConfiguration;

public class ConnectionManager {

    private static final PropertiesConfiguration properties = PropertiesManager.getInstance().getProperties();

    public static Connection getConnection() throws Exception {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            String url = properties.getString("db.jdbc.url");
            String username = properties.getString("db.jdbc.username");
            String password = properties.getString("db.jdbc.password");

            Properties props = new Properties();
            props.setProperty("user", username);
            props.setProperty("password", password);

            return DriverManager.getConnection(url, props);
        } catch (Throwable t) {
            throw new Exception("Unexpected SQLException", t);
        }
    }
}
