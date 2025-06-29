package com.dbquest.dbq.utils;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.configuration.reloading.FileChangedReloadingStrategy;

public class PropertiesManager {
    private static final String PROPERTIES_FILE_NAME = "system.properties";
    private static final PropertiesManager singletonInstance = new PropertiesManager();

    private String environment;
    String message;
    private PropertiesConfiguration properties;

    private PropertiesManager() {
        properties = new PropertiesConfiguration();
        properties.setReloadingStrategy(new FileChangedReloadingStrategy());
        try {
            properties.load(PROPERTIES_FILE_NAME);

        } catch (Exception e) {
            message = "Error loading properties " + environment + "."
                    + PROPERTIES_FILE_NAME;
        }
    }

    public static PropertiesManager getInstance() {
        return singletonInstance;
    }

    public PropertiesConfiguration getProperties() {
        return getInstance().properties;
    }

    public String getEnvironment() {
        return environment;
    }
}