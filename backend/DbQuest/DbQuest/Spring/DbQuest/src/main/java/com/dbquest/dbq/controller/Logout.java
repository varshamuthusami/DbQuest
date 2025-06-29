package com.dbquest.dbq.controller;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.dbquest.dbq.service.DBLogout;
import com.dbquest.dbq.utils.PropertiesManager;

@RestController
public class Logout {
	private static final PropertiesConfiguration properties = PropertiesManager.getInstance().getProperties();
	private static final Logger LOG = LoggerFactory.getLogger(Logout.class);
	
	 @RequestMapping("/setTokenNull")
	    @ResponseBody    
	    public void setToken(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "userid") String userid) {
		 	LOG.error(userid +  " - setTokenNull");
		 	try {
		 		if(properties.getString("api.key").equals(currentToken)) {
		 			DBLogout.setTokenNull(userid);
			 	}				
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }

}
