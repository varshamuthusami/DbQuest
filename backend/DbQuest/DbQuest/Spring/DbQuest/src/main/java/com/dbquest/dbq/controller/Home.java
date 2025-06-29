package com.dbquest.dbq.controller;

import java.util.ArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.dbquest.dbq.service.DBHome;


@RestController
public class Home {
	private static final Logger LOG = LoggerFactory.getLogger(Home.class);
	
	 @RequestMapping("/genPendingTask")
	 @ResponseBody    
	 public ArrayList<ModelMap> genPendingTask(
			 @RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
		     @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
		     @RequestParam(value = "EmpID")String EmpID) {
			 LOG.error("genPendingTask");
			ArrayList<ModelMap> model = new ArrayList<ModelMap>();
	  		model = DBHome.genPendingTask(EmpID);	  		
	     return model;
	 }	
	 
	 @RequestMapping("/getWorksheetChart" )
	 @ResponseBody    
	public ArrayList<ModelMap> getWorksheetChart(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
		 	@RequestParam(value = "UserID")String UserID) {
		 	LOG.error("getWorksheetChart");
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 	model = DBHome.getWorksheetChart(UserID);		 		
	        return model;
	 }	
}
