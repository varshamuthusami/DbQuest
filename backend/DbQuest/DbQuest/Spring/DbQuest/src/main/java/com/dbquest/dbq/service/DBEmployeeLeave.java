package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;

public class DBEmployeeLeave {

private static Connection conn = null;

private static final double OFFICE_LAT = 10.6573;
private static final double OFFICE_LNG = 77.0107;
private static final double RADIUS_METERS = 100.0;

public  static boolean isWithinOffice(double userLat, double userLng) {
    double distance = calculateDistance(OFFICE_LAT, OFFICE_LNG, userLat, userLng);
    return distance <= RADIUS_METERS;
}

public static  boolean markInTime(String empID) throws Exception {
    String sql = "INSERT INTO EmployeeAttendance (EmpID, WorkingDate, StartTime) " +
                 "SELECT ?, CONVERT(DATE, GETDATE()), GETDATE() " +
                 "WHERE NOT EXISTS (SELECT 1 FROM EmployeeAttendance " +
                 "WHERE EmpID = ? AND WorkingDate = CONVERT(DATE, GETDATE()))";

    try (Connection conn = ConnectionManager.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, empID);
        stmt.setString(2, empID);
        int rows = stmt.executeUpdate();
        return rows > 0;
    } catch (SQLException e) {
        throw new Exception("Failed to mark In-Time", e);
    }
}

public static boolean markOutTime(String empID) throws Exception {
    String sql = "UPDATE EmployeeAttendance SET EndTime = GETDATE() " +
                 "WHERE EmpID = ? AND WorkingDate = CONVERT(DATE, GETDATE()) AND EndTime IS NULL";

    try (Connection conn = ConnectionManager.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, empID);
        int rows = stmt.executeUpdate();
        return rows > 0;
    } catch (SQLException e) {
        throw new Exception("Failed to mark Out-Time", e);
    }
}

private static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    double earthRadius = 6371000; // meters
    double dLat = Math.toRadians(lat2 - lat1);
    double dLng = Math.toRadians(lng2 - lng1);
    double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
               Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
               Math.sin(dLng/2) * Math.sin(dLng/2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return earthRadius * c;
}

public static ArrayList<ModelMap> getApprovers(String empId) {
    PreparedStatement stmt = null;
    ResultSet rs = null;
    ArrayList<ModelMap> approvers = new ArrayList<ModelMap>();
    
    try {
        // Step 1: Get ELevel of the given employee
        String levelQuery = "SELECT ELevel FROM EmployeeMaster WHERE EmpID = ?";
        conn = ConnectionManager.getConnection();
        stmt = conn.prepareStatement(levelQuery);
        stmt.setString(1, empId);
        rs = stmt.executeQuery();

        int empLevel = -1;
        if (rs.next()) {
            empLevel = rs.getInt("ELevel");
        }
        conn.close();

        // Step 2: If level not found, return empty list
        if (empLevel == -1) {
            return approvers;
        }

        // Step 3: Get employees with ELevel > empLevel
        String approverQuery = "SELECT EmpID, EmpName FROM EmployeeMaster WHERE ELevel < ?";
        conn = ConnectionManager.getConnection();
        stmt = conn.prepareStatement(approverQuery);
        stmt.setInt(1, empLevel);
        rs = stmt.executeQuery();

        while (rs.next()) {
            ModelMap approver = new ModelMap();
            approver.put("empid", rs.getString("EmpID"));
            approver.put("empname", rs.getString("EmpName"));
            approvers.add(approver);
        }
        conn.close();

    } catch (SQLException e) {
        e.printStackTrace();
    } catch (Exception e) {
        e.printStackTrace();
    }

    return approvers;
}


	
	public static ArrayList<ModelMap> getEmployeeLeave(String EmpID) {		
        String sql = "select EmpID,(select EmpName from EmployeeMaster where EmpID=EmployeeLeave.EmpID),\r\n" + 
        		"   REPLACE(convert(varchar,FromDate,106),' ','/'), REPLACE(convert(varchar,ToDate,106),' ','/'),Days,Reason,Note,\r\n" + 
        		"  Approver,(select EmpName from EmployeeMaster where EmpID=EmployeeLeave.EmpID),ApprovedDate,Status \r\n" + 
        		"  from EmployeeLeave where EmpID = '" + EmpID + "' order by fromdate desc";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<ModelMap> model = new ArrayList<ModelMap>();

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	ModelMap temp = new ModelMap();
            	temp.put("empid", rs.getString(1));
              	temp.put("empname", rs.getString(2));
            	temp.put("fromdate", rs.getString(3));
            	temp.put("todate", rs.getString(4));
            	temp.put("days", rs.getString(5));
            	temp.put("reason", rs.getString(6));
            	temp.put("note", rs.getString(7));
            	temp.put("approver", rs.getString(8));
            	temp.put("approvername", rs.getString(9));
            	temp.put("approvedate", rs.getString(10));
            	temp.put("status", rs.getString(11));
            	model.add(temp);
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }       
        return model;
    }	

	public static void addEmployeeLeave(ModelMap details) throws Exception {    
	    PreparedStatement stmt = null;
	    try {
	        String sql = "INSERT INTO EmployeeLeave (EmpID,FromDate,ToDate,Reason,Note,SysDate,Approver,Status) "
	                   + " VALUES (?,?,?,'" + details.get("reason") +"', "
	                   + "'" + details.get("note") + "',getdate(), '" + details.get("approver") + "','P') ";
	        conn = ConnectionManager.getConnection();
	        stmt = conn.prepareStatement(sql);            
	        stmt.setString(1, (details.get("empid").toString().equals("") ? null : details.get("empid").toString()));
	        stmt.setString(2, (details.get("fromdate").toString().equals("") ? null : details.get("fromdate").toString()));
	        stmt.setString(3, (details.get("todate").toString().equals("") ? null : details.get("todate").toString()));            
	        stmt.executeUpdate();

	        // After successful insert, send push notification to approver
	        String approverID = details.get("approver").toString();

	        // Get approver's device token - Implement this method according to your DB
	        String approverToken = getDeviceTokenForApprover(approverID);

	        // Get employee name from empid
	        String empName = getEmployeeName(details.get("empid").toString());

	        if (approverToken != null && !approverToken.isEmpty()) {
	            sendLeaveRequestNotification(approverToken, empName, details.get("fromdate").toString(), details.get("todate").toString());
	        }

	    } catch (SQLException e) {            
	        e.printStackTrace();          
	    } finally {
	        if(stmt != null) stmt.close();
	        if(conn != null) conn.close();
	    }
	}

	// Helper method to fetch employee name by empID
	private static String getEmployeeName(String empId) throws Exception {
	    String name = "";
	    String query = "SELECT EmpName FROM EmployeeMaster WHERE EmpID = ?";
	    try (Connection conn = ConnectionManager.getConnection(); // NEW connection here
	         PreparedStatement ps = conn.prepareStatement(query)) {
	        ps.setString(1, empId);
	        try (ResultSet rs = ps.executeQuery()) {
	            if (rs.next()) {
	                name = rs.getString("EmpName");
	            }
	        }
	    }
	    return name;
	}

	// Example method: Fetch device token for approver from DB (you need to implement it)
	private static String getDeviceTokenForApprover(String approverId) {
	    String token = null;
	    String sql = "SELECT Token FROM EmployeeMaster WHERE EmpID = ?";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {

	        stmt.setString(1, approverId);
	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	                token = rs.getString("Token");
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return token;
	}

	// Example method: Send FCM push notification
	private static void sendLeaveRequestNotification(String token, String empname, String fromDate, String toDate) throws FirebaseMessagingException {
	    Notification notification = Notification.builder()
	        .setTitle("New Leave Request")
	        .setBody(empname + " requested leave from " + fromDate + " to " + toDate)
	        .build();

	    Message message = Message.builder()
	        .setToken(token)
	        .setNotification(notification)
	        .build();

	    FirebaseMessaging.getInstance().send(message);
	}

	
    public static void updateEmployeeLeave(ModelMap details) throws Exception {		
        PreparedStatement stmt;
        try {    

            String sql="update EmployeeLeave set ToDate=?,"
            	    	+ " Reason='" + details.get("reason") + "'"
            	    	+ ",Note='" + details.get("note") + "',Approver='" + details.get("approver") + "'" +" where  EmpID=? and FromDate=? ";
            
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, (details.get("todate").toString().equals("")?null:details.get("todate").toString()));
            stmt.setString(2, (details.get("empid").toString().equals("")?null:details.get("empid").toString()));
            stmt.setString(3, (details.get("fromdate").toString().equals("")?null:details.get("fromdate").toString()));
            stmt.executeUpdate();
        } catch (SQLException e) {
          e.printStackTrace();
        } 
    }

	public static void deleteEmployeeLeave(String EmpID,String FromDate) throws Exception {		
        PreparedStatement stmt;        
        try {        	
            String sql="delete from EmployeeLeave where EmpID ='" +  EmpID + "' and FromDate= '" +  FromDate + "' and Status = 'P' ";
            
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } 
    }
	
	 public static void updateEmployeePending(ModelMap details) throws Exception {			
	        PreparedStatement stmt;
	        try {    

	            String sql="update EmployeeLeave set Status=?,ApprovedDate=getdate() where EmpID=? and FromDate=? ";
	            
	            conn = ConnectionManager.getConnection();
	            stmt = conn.prepareStatement(sql);
	            stmt.setString(1, (details.get("status").toString().equals("")?null:details.get("status").toString()));
	            stmt.setString(2, (details.get("empid").toString().equals("")?null:details.get("empid").toString()));
	            stmt.setString(3, (details.get("fromdate").toString().equals("")?null:details.get("fromdate").toString()));
	            stmt.executeUpdate();
	        } catch (SQLException e) {
	          e.printStackTrace();
	        } 
	    }

	  public static ArrayList<ModelMap> getEmployeePending(String UserID) {
			
	        String sql = "SELECT " +
	                 "E.EmpID, " +
	                 "EM1.EmpName AS EmpName, " +
	                 "REPLACE(CONVERT(VARCHAR, E.FromDate, 106), ' ', '/') AS FromDate, " +
	                 "REPLACE(CONVERT(VARCHAR, E.ToDate, 106), ' ', '/') AS ToDate, " +
	                 "E.Days, " +
	                 "E.Reason, " +
	                 "E.Note, " +
	                 "E.Approver, " +
	                 "EM2.EmpName AS ApproverName, " +
	                 "E.ApprovedDate, " +
	                 "E.Status " +
	                 "FROM EmployeeLeave E " +
	                 "JOIN EmployeeMaster EM1 ON E.EmpID = EM1.EmpID " +  // Employee's name
	                 "JOIN EmployeeMaster EM2 ON E.Approver = EM2.EmpID " +  // Approver's name
	                 "WHERE E.Approver = '" + UserID + "' AND E.Status = 'P'";  // Directly inject UserID into the query ;

	        PreparedStatement pStmt = null;
	        ResultSet rs = null;
	        ArrayList<ModelMap> model = new ArrayList<ModelMap>();

	        try {
	            conn = ConnectionManager.getConnection();
	            pStmt = conn.prepareStatement(sql);
	            rs = pStmt.executeQuery();

	            while (rs.next()) {
	            	ModelMap temp = new ModelMap();
	            	temp.put("empid", rs.getString(1));
	              	temp.put("empname", rs.getString(2));
	            	temp.put("fromdate", rs.getString(3));
	            	temp.put("todate", rs.getString(4));
	            	temp.put("days", rs.getString(5));
	            	temp.put("reason", rs.getString(6));
	            	temp.put("note", rs.getString(7));
	            	temp.put("approver", rs.getString(8));
	            	temp.put("approvername", rs.getString(9));
	            	temp.put("approvedate", rs.getString(10));
	            	temp.put("status", rs.getString(11));
	            	model.add(temp);
	            }
	            conn.close();
	        } catch (Exception e) {
	            e.printStackTrace();
	        } 	      
	        return model;
	    }	
	  public static ArrayList<ModelMap> getEmployeeAttendance(String UserID) {
			
		  String sql = "SELECT "
		             + "    FORMAT(WorkingDate, 'dd') AS Datein, "
		             + "    FORMAT(WorkingDate, 'dddd') AS DayName, "
		             + "    FORMAT(StartTime, 'hh:mm tt') AS InTime,  "
		             + "    FORMAT(EndTime, 'hh:mm tt') AS OutTime, "
		             + "    CONCAT("
		             + "        DATEDIFF(MINUTE, StartTime, EndTime) / 60, ' h '," 
		             + "        DATEDIFF(MINUTE, StartTime, EndTime) % 60, ' m'"
		             + "    ) AS TotalHours,"
		             + "    FORMAT(WorkingDate, 'MMMM yyyy') AS Month "
		             + "FROM [EmployeeAttendance] "
		             + "WHERE EmpID = ? "
		             + "ORDER BY FORMAT(WorkingDate, 'yyyy-MM') DESC, WorkingDate DESC";

		PreparedStatement pStmt = null;
		ResultSet rs = null;
		ArrayList<ModelMap> model = new ArrayList<ModelMap>();

		try {
			 conn = ConnectionManager.getConnection();
		    pStmt = conn.prepareStatement(sql);
		    pStmt.setString(1, UserID);  // Bind the UserID parameter
		    rs = pStmt.executeQuery();

		    while (rs.next()) {
		        ModelMap temp = new ModelMap();
		        temp.put("Datein", rs.getString(1));
		        temp.put("DayName", rs.getString(2));
		        temp.put("InTime", rs.getString(3));
		        temp.put("OutTime", rs.getString(4));
		        temp.put("TotalHours", rs.getString(5));
		        temp.put("Month", rs.getString(6));
		        model.add(temp);
		    }
		} catch (SQLException e) {
		    e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
		    try {
		        if (rs != null) rs.close();
		        if (pStmt != null) pStmt.close();
		        if (conn != null) conn.close();
		    } catch (SQLException ex) {
		        ex.printStackTrace();
		    }
		}

		return model;

	    }
	     
	  
	  public static boolean approveLeaveRequest(String empId, String fromDate, String approverId) {
		    String sql = "UPDATE EmployeeLeave SET ApprovedDate = GETDATE(), Status = 'A' " +
		                 "WHERE (Approver = ? AND EmpID = ?) AND FromDate = CONVERT(date, ?, 103)"; // Assuming date is in dd/MM/yyyy

		    try (Connection conn = ConnectionManager.getConnection();
		         PreparedStatement stmt = conn.prepareStatement(sql)) {
		        stmt.setString(1, approverId);
		        stmt.setString(2, empId);
		        stmt.setString(3, fromDate); 
		        int rows = stmt.executeUpdate();

		        if (rows > 0) {
		            // Fetch employee device token from DB
		            String empToken = getDeviceTokenForApprover(empId);

		            // Fetch employee name for personalized notification
		            String empName = getEmployeeName(empId);

		            if (empToken != null && !empToken.isEmpty()) {
		                sendLeaveApprovalNotification(empToken, empName, fromDate);
		            }

		            return true;
		        }
		    } catch (Exception e) {
		        e.printStackTrace();
		    }
		    return false;
		}
	  
	  private static void sendLeaveApprovalNotification(String token, String empName, String fromDate) throws FirebaseMessagingException {
		    Notification notification = Notification.builder()
		        .setTitle("Leave Approved")
		        .setBody("Hi " + empName + ", your leave starting from " + fromDate + " has been approved.")
		        .build();

		    Message message = Message.builder()
		        .setToken(token)
		        .setNotification(notification)
		        .build();

		    FirebaseMessaging.getInstance().send(message);
		}

	  public static ArrayList<ModelMap> getEmployeesOnLeaveToday() {
		    String sql = "SELECT EmpID, (SELECT EmpName FROM EmployeeMaster WHERE EmpID = E.EmpID), " +
		                 "REPLACE(CONVERT(varchar, FromDate, 106), ' ', '/'), " +
		                 "REPLACE(CONVERT(varchar, ToDate, 106), ' ', '/'), Days, Reason " +
		                 "FROM EmployeeLeave E " +
		                 "WHERE CONVERT(date, GETDATE()) BETWEEN FromDate AND ToDate AND Status = 'A'";

		    ArrayList<ModelMap> model = new ArrayList<>();

		    try (Connection conn = ConnectionManager.getConnection();
		         PreparedStatement stmt = conn.prepareStatement(sql);
		         ResultSet rs = stmt.executeQuery()) {
		        while (rs.next()) {
		            ModelMap temp = new ModelMap();
		            temp.put("empid", rs.getString(1));
		            temp.put("empname", rs.getString(2));
		            temp.put("fromdate", rs.getString(3));
		            temp.put("todate", rs.getString(4));
		            temp.put("days", rs.getString(5));
		            temp.put("reason", rs.getString(6));
		            model.add(temp);
		        }
		    } catch (Exception e) {
		        e.printStackTrace();
		    }
		    System.out.print("employee on leave "+model);
		    return model;
		}



}
