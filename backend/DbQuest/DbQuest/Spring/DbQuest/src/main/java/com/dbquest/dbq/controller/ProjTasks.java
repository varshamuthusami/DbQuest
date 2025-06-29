package com.dbquest.dbq.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.dbquest.dbq.service.DBProjTasks;

import jakarta.servlet.http.HttpServletResponse;

@RestController
public class ProjTasks {
	
	String FILE_PATH = "",FILE_NAME= "",FOLDER_PATH="";
	String UPLOAD_FOLDER = "C:\\Users\\Administrator\\Desktop\\DbQ";
	String FOLDER_PATH_PID="",FOLDER_PATH_TASKID="";
	
	private static final Logger LOG = LoggerFactory.getLogger(ProjTasks.class);
	
	@RequestMapping("/getProjTaskSpinnersData")
	@ResponseBody    
	public ArrayList<ModelMap> getProjTaskSpinnersData(
	        @RequestHeader(value = "currentToken", defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken) {
	    LOG.error("getProjTaskSpinnersData");
	    ArrayList<ModelMap> model = DBProjTasks.getProjTaskSpinnersData();
	    return model;
	}
	
	@RequestMapping("/saveFcmToken")
	@ResponseBody    
	public String saveFcmToken(
	        @RequestHeader(value = "currentToken", defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken, 
	        @RequestParam(value = "empId") String empId,
	        @RequestParam(value = "fcmtoken") String fcmtoken){
	    LOG.error("saveFcmToken");
	    String model = null;
		try {
			model = DBProjTasks.saveFcmToken(empId, fcmtoken);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	    return model;
	}


	
	@RequestMapping(value = "/addProjTasks", method = RequestMethod.POST, consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	@ResponseBody    
	public ResponseEntity<?> addProjTasks(
	    @RequestHeader(value = "currentToken") String currentToken,
	    @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	    @RequestParam("pid") String pid,
	    @RequestParam("ttype") String ttype,
	    @RequestParam("tdesc") String tdesc,
	    @RequestParam("sdate") String sdate,
	    @RequestParam("edate") String edate,
	    @RequestParam("cby") String cby,
	    @RequestParam("ato") String ato,
	    @RequestParam(value = "file", required = false) MultipartFile file
	) {
	    try {
	        ModelMap taskDetails = new ModelMap();
	        taskDetails.put("pid", pid);
	        taskDetails.put("ttype", ttype);
	        taskDetails.put("tdesc", tdesc);
	        taskDetails.put("sdate", sdate);
	        taskDetails.put("edate", edate);
	        taskDetails.put("cby", cby);
	        taskDetails.put("ato", ato);

	        DBProjTasks.addProjTasks(taskDetails, file); // updated method to accept file
	        return new ResponseEntity<>("Task Created", HttpStatus.OK);
	    } catch (Exception e) {
	        LOG.error(e.toString());
	        e.printStackTrace();
	        return new ResponseEntity<>("Failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
	    }
	}

	 
	@RequestMapping(value = "/updateProjTasks", method = RequestMethod.POST, consumes = {"multipart/form-data"})
	@ResponseBody
	public void updateProjTasks(
	    @RequestHeader(value = "currentToken") String currentToken,
	    @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	    @RequestParam Map<String, String> params,
	    @RequestPart(value = "file", required = false) MultipartFile file) {

	    try {
	        ModelMap model = new ModelMap();
	        model.addAllAttributes(params);
	        DBProjTasks.updateProjTasks(model, file);
	    } catch (Exception e) {
	        LOG.error("Error updating project task: " + e.getMessage(), e);
	        e.printStackTrace();
	    }
	}

	 
	 @RequestMapping(value="/deleteProjectTask", method=RequestMethod.DELETE)
	    @ResponseBody    
	    public void deleteProjectTask(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "pid") String pid,
	        @RequestParam(value = "taskid") String taskid){
		 	try {
		 		DBProjTasks.deleteProjectTask(pid,taskid);		
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 @RequestMapping("/getProjTaskList")
	    @ResponseBody    
	    public ArrayList<ModelMap> getProjTaskList(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "UserID") String UserID) {
		 	LOG.error("getProjTaskList");
		 	ArrayList<ModelMap> model = DBProjTasks.getProjTaskList(UserID);
	        return model;
	    }
	 @RequestMapping("/getPendingTasks")
	    @ResponseBody    
	    public ArrayList<ModelMap> getPendingTasks(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "UserID") String UserID) {
		 	LOG.error("getPendingTasks");
		 	ArrayList<ModelMap> model = DBProjTasks.getPendingTasks(UserID);
	        return model;
	    }
	 
	 @RequestMapping("/getTasksByEmpIdAndProjectId")
	    @ResponseBody    
	    public ArrayList<ModelMap> getTasksByEmpIdAndProjectId(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "UserID") String UserID,
	        @RequestParam(value = "projectID") String projectID){
		 	LOG.error("getTasksByEmpIdAndProjectId");
		 	ArrayList<ModelMap> model = DBProjTasks.getTasksByEmpIdAndProjectId(UserID,projectID);
	        return model;
	    }
	 
	 @RequestMapping("/getProjList")
	    @ResponseBody    
	    public ArrayList<ModelMap> getProjList(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "UserID") String UserID) {
		 	LOG.error("getProjList");
		 	ArrayList<ModelMap> model = DBProjTasks.getProjList(UserID);
	        return model;
	    }	
	 
	 @RequestMapping("/getprojecttaskbasedElevel")
	    @ResponseBody    
	    public ArrayList<ModelMap> getprojecttaskbasedElevel(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "empId") String empId) {
		 	LOG.info("getprojecttaskbasedElevel");
		 	ArrayList<ModelMap> model = DBProjTasks.getprojecttaskbasedElevel(empId);
	        return model;
	    }	
	 
	 
	 
	 @RequestMapping("/getprojecttask" )
	    @ResponseBody    
	  public ArrayList<ModelMap> getprojecttask(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken) {
		 	LOG.error("getprojecttask");
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 //	if(properties.getString("api.key").equals(currentToken)) {
		 		model = DBProjTasks.getprojecttask();
		// 	}
	        return model;
	    }	 
	 
	 @RequestMapping(value = "/Projecttaskupload", method = RequestMethod.POST, consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	 public ResponseEntity<Object> uploadfile(
	     @RequestParam("file") MultipartFile file,
	     @RequestParam(value = "pid") String pid,
	     @RequestParam(value = "taskid") String taskid
	 ) throws IOException {

	     String UPLOAD_FOLDER = "D:\\varsha\\projects";
	     String FILE_NAME = file.getOriginalFilename();

	     String folderPathPid = UPLOAD_FOLDER + File.separator + pid;
	     File directoryPid = new File(folderPathPid);
	     if (!directoryPid.exists()) {
	         boolean created = directoryPid.mkdirs();
	         if (!created) {
	             return new ResponseEntity<>("Failed to create project directory", HttpStatus.INTERNAL_SERVER_ERROR);
	         }
	         directoryPid.setReadable(true, false);
	         directoryPid.setWritable(true, false);
	         directoryPid.setExecutable(true, false);
	     }

	     String folderPathTaskId = folderPathPid + File.separator + taskid;
	     File directoryTask = new File(folderPathTaskId);
	     if (!directoryTask.exists()) {
	         boolean created = directoryTask.mkdirs();
	         if (!created) {
	             return new ResponseEntity<>("Failed to create task directory", HttpStatus.INTERNAL_SERVER_ERROR);
	         }
	         directoryTask.setReadable(true, false);
	         directoryTask.setWritable(true, false);
	         directoryTask.setExecutable(true, false);
	     }

	     String filePath = folderPathTaskId + File.separator + FILE_NAME;
	     File convertFile = new File(filePath);

	     if (!convertFile.exists()) {
	         convertFile.createNewFile();
	     }

	     try (FileOutputStream fout = new FileOutputStream(convertFile)) {
	         fout.write(file.getBytes());
	     }

	     try {
	         DBProjTasks.updateprojecttask(pid, taskid, FILE_NAME);
	     } catch (Exception e) {
	         e.printStackTrace();
	     }

	     return new ResponseEntity<>("File Upload Successful", HttpStatus.OK);
	 }

		 
}
	  @Controller
		 @RequestMapping("/ProjectTaskDownload")
		  class TaskDownload {
		  
			String FILE_PATH = "",FILE_NAME= "",FOLDER_PATH="";
			String UPLOAD_FOLDER = "D:\\varsha\\projects";
			private static final Logger LOG = LoggerFactory.getLogger(ProjTasks.class);
			private static final String APPLICATION_OCTET_STREAM = "application/octet-stream";

		     @RequestMapping(value = "/file", method = RequestMethod.GET,produces = APPLICATION_OCTET_STREAM)
		      public @ResponseBody void downloadA(
		    	 HttpServletResponse response,
		    	 @RequestParam(value = "FileName") String FileName,
		    	 @RequestParam(value = "PID") String PID,
		    	 @RequestParam(value = "TASKID") String TASKID) throws IOException{
		    	
		    	 LOG.error("ProjectTaskDownload");
		    	 
		    	 FILE_PATH = UPLOAD_FOLDER+"\\" + PID + "\\"+ TASKID + "\\" + FileName + "";
		    	 
		         File file = getFile(FILE_PATH);
		         
		         InputStream in = new FileInputStream(file);

		         response.setContentType(APPLICATION_OCTET_STREAM);
		         response.setHeader("Content-Disposition", "attachment; filename=" + FileName);
		         response.setHeader("Content-Length", String.valueOf(file.length()));
		         FileCopyUtils.copy(in, response.getOutputStream());
		     }

		   
		     private File getFile(String name) throws FileNotFoundException {
		         File file = new File(name);
		         if (!file.exists()){
		        	 throw new FileNotFoundException("file with path: " + FILE_PATH + " was not found.");
		         }
		         return file;
		     }

}
