package com.dbquest.dbq.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.dbquest.dbq.service.DBEmployee;

@RestController
public class Employee {
	private static final Logger LOG = LoggerFactory.getLogger(DBEmployee.class);
	
	@RequestMapping("/getEmpProfile")
	@ResponseBody    
	public ModelMap getEmpProfile(
		@RequestHeader(value = "currentToken") String currentToken,
	    @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	    @RequestParam(value = "EmpID") String empid) {
	 	LOG.error("getEmpProfile");
	 	ModelMap model = DBEmployee.getEmpProfile(empid);
	    return model;
	}
	
	@RequestMapping("/updateEmpApp")
    @ResponseBody    
     public void updateEmpApp(
   		  @RequestBody ModelMap value
   		  ) {
	  	try {
	  		DBEmployee.updateEmpApp(value);	
		} catch (Exception e) {
			// TODO Auto-generated catch block
			LOG.error(e.toString());
			e.printStackTrace();
		}
	 }		
}