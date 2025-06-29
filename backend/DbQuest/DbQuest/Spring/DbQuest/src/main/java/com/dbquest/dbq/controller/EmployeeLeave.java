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

import com.dbquest.dbq.service.DBEmployeeLeave;

@RestController
public class EmployeeLeave {

	private static final Logger LOG = LoggerFactory.getLogger(EmployeeLeave.class);
	
	@RequestMapping("/getApprovers")
	@ResponseBody
	public ArrayList<ModelMap> getApprovers(
	    @RequestHeader(value = "currentToken", defaultValue = "") String currentToken,
	    @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
		@RequestParam(value = "empId")String empId) {
	    LOG.error("getApprovers");

	    // Fetch the approvers from the database
	    ArrayList<ModelMap> model = DBEmployeeLeave.getApprovers(empId);
	    
	    return model;
	}
 
	
	
	 @RequestMapping("/getEmployeeLeave" )
	 @ResponseBody    
	 public ArrayList<ModelMap> getEmployeeLeave(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "EmpID")String EmpID) {
		 
		 	LOG.error("getEmployeeLeave");
		 	
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 		model = DBEmployeeLeave.getEmployeeLeave(EmpID);
		 		
	        return model;
	    }	 
	
	 @RequestMapping("/addEmployeeLeave")
	 @ResponseBody    
	 public void addEmployeeLeave(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		DBEmployeeLeave.addEmployeeLeave(value);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }

	 @RequestMapping("/updateEmployeeLeave")
	 @ResponseBody    
	 public void updateEmployeeLeave(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		DBEmployeeLeave.updateEmployeeLeave(value);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 @RequestMapping("/getEmployeeAttendance" )
	 @ResponseBody    
	 public ArrayList<ModelMap> getEmployeeAttendance(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "EmpID")String EmpID) {
		 
		 	LOG.error("getEmployeeAttendance");
		 	
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 		model = DBEmployeeLeave.getEmployeeAttendance(EmpID);
		 		
	        return model;
	    }	
	 @RequestMapping("/getEmployeePending" )
	 @ResponseBody    
	 public ArrayList<ModelMap> getEmployeePending(
	    	@RequestHeader(value = "currentToken",defaultValue = "") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "EmpID")String EmpID) {
		 
		 	LOG.error("getEmployeePending");
		 	
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 		model = DBEmployeeLeave.getEmployeePending(EmpID);
		 		
	        return model;
	    }
	 
	 @RequestMapping("/getEmployeesOnLeaveToday" )
	 @ResponseBody    
	 public ArrayList<ModelMap> getEmployeesOnLeaveToday(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken) {
		 
		 	LOG.info("getEmployeesOnLeaveToday");
		 	
		 	ArrayList<ModelMap> model = new ArrayList<ModelMap>();
		 		model = DBEmployeeLeave.getEmployeesOnLeaveToday();
		 		
	        return model;
	    }
	 
	 
	 @RequestMapping("/approveLeaveRequest" )
	 @ResponseBody    
	 public boolean approveLeaveRequest(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "empId") String empId,
	        @RequestParam(value = "fromDate") String fromDate,
	        @RequestParam(value = "approverId") String approverId) {
		 
		 	LOG.info("approveLeaveRequest");
		 	
		 	boolean model;
		 		model = DBEmployeeLeave.approveLeaveRequest(empId, fromDate, approverId);
		 		
	        return model;
	    }
	 
	 
	 
	 @RequestMapping(value="/deleteEmployeeLeave", method=RequestMethod.DELETE)
	 @ResponseBody    
	 public void deleteEmployeeLeave(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "EmpID") String EmpID,
	        @RequestParam(value = "FromDate") String FromDate){
		 	try {
		 		DBEmployeeLeave.deleteEmployeeLeave(EmpID,FromDate);		
			} catch (Exception e) {
				// TODO Auto-generated catch block
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 @RequestMapping("/updateEmployeePending")
	 @ResponseBody    
	 public void updateEmployeePending(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestBody ModelMap value) {
		 	try {
		 		DBEmployeeLeave.updateEmployeePending(value);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 @RequestMapping("/markInTime")
	 @ResponseBody    
	 public void markInTime(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "empID") String empID ){
		 	try {
		 		DBEmployeeLeave.markInTime(empID);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 @RequestMapping("/markOutTime")
	 @ResponseBody    
	 public void markOutTime(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "empID") String empID ){
		 	try {
		 		DBEmployeeLeave.markOutTime(empID);	
			} catch (Exception e) {
				LOG.error(e.toString());
				e.printStackTrace();
			}
	    }
	 
	 @RequestMapping("/markAttendance")
	 @ResponseBody
	 public String markAttendance(
	         @RequestHeader(value = "currentToken") String currentToken,
	         @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	         @RequestParam(value = "empID") String empID,
	         @RequestParam(value = "lat") double lat,
	         @RequestParam(value = "lng") double lng) {

	     try {
	         if (!DBEmployeeLeave.isWithinOffice(lat, lng)) {
	             return "Location check failed for empID: " + empID;
	            
	         }

	         boolean markedIn = DBEmployeeLeave.markInTime(empID);
	         if (markedIn) {
	             return "In-time marked for empID: " + empID;
	         } else {
	             boolean markedOut = DBEmployeeLeave.markOutTime(empID);
	             if (markedOut) {
	                 return "Out-time marked for empID: " + empID;
	             } else {
	                 return "Both In-time and Out-time already marked for empID: " + empID;
	             }
	         }
	     } catch (Exception e) {
	         return "Error while marking attendance: " + e.getMessage();
	     }
	 }

}
