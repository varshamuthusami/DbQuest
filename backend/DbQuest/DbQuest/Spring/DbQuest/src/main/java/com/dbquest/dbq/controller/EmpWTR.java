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

import com.dbquest.dbq.service.DBEmpWTR;

@RestController
public class EmpWTR {
	
	private static final Logger LOG = LoggerFactory.getLogger(EmpWTR.class);
	
	 @RequestMapping("/getTodayWtr")
	    @ResponseBody    
	    public ModelMap getTodayWtr(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "userid") String userid) {
		 	LOG.error("getTodayWtr");
		 	ModelMap model = DBEmpWTR.getTodayWtr(userid);		 	
	        return model;
	    }	 
	 
	 @RequestMapping("/addWtr")
	    @ResponseBody    
	    public void addWtr(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		DBEmpWTR.addWtr(value);		 		
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 @RequestMapping(value="/deleteEmployeeWtr", method=RequestMethod.DELETE)
	 @ResponseBody    
	 public void deleteEmployeeWtr(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "EmpID") String EmpID,
	        @RequestParam(value = "WType") String WType){
		 	try {
		 		DBEmpWTR.deleteEmployeeWtr(EmpID,WType);		
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 @RequestMapping("/getEmpAttList")
	    @ResponseBody    
	    public ArrayList<ModelMap> getEmpAttList(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "UserID") String UserID) {
		 	LOG.error("getEmpAttList");
		 	ArrayList<ModelMap> model = DBEmpWTR.getEmpAttList(UserID);
	        return model;
	    }	
	 
	 @RequestMapping("/getEmpAttViewList")
	    @ResponseBody    
	    public ArrayList<ModelMap> getEmpAttViewList(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "UserID") String UserID,
	        @RequestParam(value = "WMonth") String WMonth,
	        @RequestParam(value = "WYear") String WYear) {
		 	LOG.error("getEmpAttViewList");
		 	ArrayList<ModelMap> model = DBEmpWTR.getEmpAttViewList(UserID,WMonth,WYear);
	        return model;
	    }	
	
}
