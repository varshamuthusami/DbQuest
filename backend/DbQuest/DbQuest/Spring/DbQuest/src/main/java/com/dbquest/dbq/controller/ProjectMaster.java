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

import com.dbquest.dbq.service.DBProjectMaster;

@RestController
public class ProjectMaster {
	
	private static final Logger LOG = LoggerFactory.getLogger(ProjectMaster.class);
	
	 @RequestMapping("/getProjectMaster" )
	 @ResponseBody    
	public ArrayList<ModelMap> getProjectMaster(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken) {
		 
		 	LOG.error("getProjectMaster");
		 	
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 		model = DBProjectMaster.getProjectMaster();
		 		
	        return model;
	    }
	 @RequestMapping("/getProjMasterSpinnersData" )
	 @ResponseBody    
	public ArrayList<ModelMap> getProjMasterSpinnersData(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken) {
		 
		 	LOG.error("getProjMasterSpinnersData");
		 	
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 		model = DBProjectMaster.getProjMasterSpinnersData();
		 		
	        return model;
	    }
	 
	 
	@RequestMapping("/addProjectMaster")
	@ResponseBody    
	public void addProjectMaster(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		DBProjectMaster.addProjectMaster(value);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	
	
	 @RequestMapping("/updateProjectMaster")
	    @ResponseBody    
	    public void updateProjectMaster(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		LOG.error("updateProjectMaster");
			 	
		 		DBProjectMaster.updateProjectMaster(value);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 
	 @RequestMapping(value="/deleteProject", method=RequestMethod.DELETE)
	    @ResponseBody    
	 public void deleteProject(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "pid") String pid){
		 	try {
		 		DBProjectMaster.deleteProject(pid);		
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
}
