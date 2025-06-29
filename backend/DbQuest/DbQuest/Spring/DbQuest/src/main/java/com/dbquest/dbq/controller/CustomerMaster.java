package com.dbquest.dbq.controller;

import java.util.ArrayList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.dbquest.dbq.service.DBCustomerMaster;

@RestController
public class CustomerMaster {
	
	private static final Logger LOG = LoggerFactory.getLogger(CustomerMaster.class);
	
	 @RequestMapping("/getCustomerMaster" )
	 @ResponseBody    
	public ArrayList<ModelMap> getCustomerMaster(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken) {
		 
		 	LOG.error("getCustomerMaster");
		 	
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 		model = DBCustomerMaster.getCustomerMaster();
		 		
	        return model;
	    }	 
	 
	 
	@RequestMapping("/addCustomerMaster")
	@ResponseBody    
	public void addCustomerMaster(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		DBCustomerMaster.addCustomerMaster(value);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	
	
	 @RequestMapping("/updateCustomerMaster")
	    @ResponseBody    
	    public void updateCustomerMaster(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		LOG.error("updateCustomerMaster");
			 	
		 		DBCustomerMaster.updateCustomerMaster(value);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 
	 @RequestMapping(value="/deleteCustomer", method=RequestMethod.DELETE)
	    @ResponseBody    
	 public void deleteCustomer(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "cuscode") String cuscode){
		 	try {
		 		DBCustomerMaster.deleteCustomer(cuscode);		
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
}
