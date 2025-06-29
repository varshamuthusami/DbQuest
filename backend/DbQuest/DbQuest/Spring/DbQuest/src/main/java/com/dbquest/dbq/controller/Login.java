package com.dbquest.dbq.controller;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.slf4j.LoggerFactory;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.dbquest.dbq.service.DBLogin;
import com.dbquest.dbq.utils.PropertiesManager;

@RestController
@CrossOrigin(origins = "*")
public class Login {
	private static final PropertiesConfiguration properties = PropertiesManager.getInstance().getProperties();
	private static final Logger LOG = LoggerFactory.getLogger(Login.class);
	
	 @RequestMapping("/getUserInfo")
	    @ResponseBody    
	    public ModelMap getUserInfo(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "userid") String userid,
	        @RequestParam(value = "password") String password) {
		 	LOG.error("getUserInfo");
		 	ModelMap model = DBLogin.getUserInfo(userid, password);		 	
	        return model;
	    }	 
	 
	 @RequestMapping("/updateToken")
	    @ResponseBody    
	    public void updateToken(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "token") String Token,
	        @RequestParam(value = "uid") String Uid,
	        @RequestParam(value = "type") String Type) {
		 	try {
		 		DBLogin.updateToken(Token,Uid,Type);			 			 		
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 @RequestMapping("/getToken")
	    @ResponseBody
	    public String getToken() {
	        // Return the static api.key, e.g. "token"
	        return properties.getString("api.key");
	    }
	
}
