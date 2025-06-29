package com.dbquest.dbq.controller;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.dbquest.dbq.service.DBChangePassword;

@RestController
public class ChangePassword {
	private static final Logger LOG = LoggerFactory.getLogger(ChangePassword.class);

	@RequestMapping("/getCurrentPass")
    @ResponseBody    
    public ModelMap getCurrentPass(
        @RequestHeader(value = "currentToken") String currentToken,
	    @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
		@RequestParam(value = "UserID") String UserID) {
	 	LOG.error("getCurrentPass");
	 	ModelMap model = DBChangePassword.getCurrentPass(UserID);
	    return model;
    }	
	 
	 @RequestMapping("/updatePassword")
     @ResponseBody    
      public void updatePassword(
    		  @RequestBody ModelMap value
    		  ) {
	  	try {
	  		DBChangePassword.updatePassword(value);	
		} catch (Exception e) {
			// TODO Auto-generated catch block
			LOG.error(e.toString());
			e.printStackTrace();
		}
	 }	 	
	 @RequestMapping("/generateOtp")
	 @ResponseBody
	 public boolean generateOtp(
	         
			 @RequestParam(value = "email") String email) {
	     
	     LOG.info("generateOtp");

	     
	     boolean status = false;

	     try {
	         status = DBChangePassword.generateAndSendOtp(email);
	     } catch (Exception e) {
	         e.printStackTrace();
	     }

	     return status;
	 }
	 @RequestMapping("/verifyAndResetPassword")
	 @ResponseBody
	 public boolean verifyAndResetPassword(
	        
			 @RequestParam(value = "email") String email,
			 @RequestParam(value = "enteredOtp") String enteredOtp,
			 @RequestParam(value = "newPassword") String newPassword) {
	     
	     LOG.info("verifyAndResetPassword");


	     boolean result = false;

	     try {
	         result = DBChangePassword.verifyAndResetPassword(email, enteredOtp, newPassword);
	     } catch (Exception e) {
	         e.printStackTrace();
	     }

	     return result;
	 }

}
