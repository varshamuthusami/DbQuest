package com.dbquest.dbq.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.dbquest.dbq.model.SpnTask;
import com.dbquest.dbq.service.DBEmpWS;
import com.dbquest.dbq.service.DBProjTasks;

@RestController
public class EmpWS {
	
	private static final Logger LOG = LoggerFactory.getLogger(EmpWS.class);
	
	 @RequestMapping("/getEmpWSSpinnersData")
	 @ResponseBody    
	 public ArrayList<ModelMap> getEmpWSSpinnersData(
			 @RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
		     @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
		     @RequestParam(value = "EmpID")String EmpID) {
			 	LOG.error("getEmpWSSpinnersData");
			ArrayList<ModelMap> model = new ArrayList<ModelMap>();
	  		model = DBEmpWS.getEmpWSSpinnersData(EmpID);
	     return model;
	 }		
	 
	 @RequestMapping("/addEmpWS")
	    @ResponseBody    
	    public int addEmpWS(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody Map<?, ?> value) throws Exception {
		    LOG.error("getSpnTask");
		 	int WSID = DBEmpWS.addEmpWS(value);
		 	return WSID;
		 	
	    }	 
	 
	 @RequestMapping("/getSpnTask")
	    @ResponseBody    
	    public ArrayList<SpnTask> getSpnTask(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "pid") String pid,
	        @RequestParam(value = "userid") String userid) {
		 	LOG.error("getSpnTask");
		 	ArrayList<SpnTask> items = new ArrayList<SpnTask>();
		 	items = DBEmpWS.getSpnTask(pid,userid);
	        return items;
	    } 
	 
	 
	 @RequestMapping("/getWSList")
	    @ResponseBody    
	    public ArrayList<ModelMap> getWSList(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "UserID") String UserID,
	        @RequestParam(value = "WMonth") String WMonth,
	        @RequestParam(value = "WYear") String WYear) {
		 	LOG.error("getWSList");
		 	ArrayList<ModelMap> model = DBEmpWS.getWSList(UserID,WMonth,WYear);
	        return model;
	    }	
	 
	 @RequestMapping("/deleteWS")
	    @ResponseBody    
	    public void deleteWS(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "wsid") String wsid,
	        @RequestParam(value = "empid") String empid) {
		 	try {
		 		DBEmpWS.deleteWS(wsid,empid);			 		 		
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 @RequestMapping("/getAccessibleEmployees")
	    @ResponseBody    
	    public ArrayList<ModelMap> getAccessibleEmployees(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "empid") String empid) throws Exception {
		 	LOG.error("getAccessibleEmployees");
		 	ArrayList<ModelMap> model = DBEmpWS.getAccessibleEmployees(empid);
	        return model;
	    }
	 
	 @RequestMapping("/getTasks")
	    @ResponseBody    
	    public List<Map<String, String>> getTasks(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "pid") String pid) throws Exception {
		 	LOG.error("getTasks");
		 	List<Map<String, String>> model = DBEmpWS.getTasks(pid);
	        return model;
	    }
	 
	 @RequestMapping("/getDOJOfEmployee")
	    @ResponseBody    
	    public String getDOJOfEmployee(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "selectedEmpId") String selectedEmpId) throws Exception {
		 	LOG.error("getDOJOfEmployee");
		 	String model = DBEmpWS.getDOJOfEmployee(selectedEmpId);
	        return model;
	    }
	 
	 @RequestMapping(value = "/WStaskupload", method = RequestMethod.POST, consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	 public ResponseEntity<Object> uploadfile(
	     @RequestParam("file") MultipartFile file,
	     @RequestParam(value = "pid") String pid,
	     @RequestParam(value = "WSID") String WSID,
	     @RequestParam(value = "taskid", required = false) String taskid
	 ) throws IOException {

	     String UPLOAD_FOLDER = "D:\\varsha\\worksheet\\projects";
	     String FILE_NAME = file.getOriginalFilename();

	     if (FILE_NAME == null || FILE_NAME.isEmpty()) {
	         return new ResponseEntity<>("Filename is invalid", HttpStatus.BAD_REQUEST);
	     }

	     String folderPathPid = UPLOAD_FOLDER + File.separator + pid;
	     File directoryPid = new File(folderPathPid);
	     if (!directoryPid.exists() && !directoryPid.mkdirs()) {
	         return new ResponseEntity<>("Failed to create project directory", HttpStatus.INTERNAL_SERVER_ERROR);
	     }

	     String folderPathFinal;
	     if (taskid != null && !taskid.isEmpty()) {
	         folderPathFinal = folderPathPid + File.separator + taskid;
	     } else {
	         folderPathFinal = folderPathPid + File.separator + "general"; // Save to a general folder
	         taskid = null; // Ensure null is passed to DB update
	     }

	     File directoryFinal = new File(folderPathFinal);
	     if (!directoryFinal.exists() && !directoryFinal.mkdirs()) {
	         return new ResponseEntity<>("Failed to create task/general directory", HttpStatus.INTERNAL_SERVER_ERROR);
	     }

	     File convertFile = new File(folderPathFinal + File.separator + FILE_NAME);
	     if (!convertFile.exists()) {
	         convertFile.createNewFile();
	     }

	     try (FileOutputStream fout = new FileOutputStream(convertFile)) {
	         fout.write(file.getBytes());
	     }

	     try {
	         DBEmpWS.updateWorksheetAttachment(pid, WSID, taskid, FILE_NAME); // 👈 this is what you need to implement
	     } catch (Exception e) {
	         e.printStackTrace();
	     }

	     return new ResponseEntity<>("File Upload Successful", HttpStatus.OK);
	 }
	 
		 
}
