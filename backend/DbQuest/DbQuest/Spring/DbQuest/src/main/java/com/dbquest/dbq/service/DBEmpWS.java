package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.ui.ModelMap;

import com.dbquest.dbq.model.SpnTask;
import com.dbquest.dbq.utils.ConnectionManager;

public class DBEmpWS {
	private static Connection conn = null;
	private static int taskid;
	
	public static ArrayList<ModelMap> getEmpWSSpinnersData(String EmpID) {
	    
		 String sql = "SELECT ProjectID,ProjectDesc + ' - ' + ParamDesc FROM ProjectMaster A, Parameter B "
		 		+ " WHERE A.Technology = B.ParamID AND ParamType = 'TEC'";
		 		 
		 String sql2 = "SELECT ParamID,ParamDesc FROM Parameter WHERE ParamType = 'WTY'";
		 
	    PreparedStatement pStmt = null;
	    ResultSet rs = null;
	    ArrayList<ModelMap> model = new ArrayList<ModelMap>();

	    PreparedStatement pStmt2 = null;
	    ResultSet rs2 = null;
	    ArrayList<ModelMap> model2 = new ArrayList<ModelMap>();

	    ArrayList<ModelMap> modela = new ArrayList<ModelMap>();
	    try {
	        conn = ConnectionManager.getConnection();
	        pStmt = conn.prepareStatement(sql);
	        rs = pStmt.executeQuery();

	        while (rs.next()) {
	        	ModelMap temp = new ModelMap();
           	temp.put("sCode", rs.getString(1));
           	temp.put("sDesc", rs.getString(2));
           	model.add(temp);
	        }
	        conn.close();
	    	        
	        conn = ConnectionManager.getConnection();
	        pStmt2 = conn.prepareStatement(sql2);
	        rs2 = pStmt2.executeQuery();

	        while (rs2.next()) {
	        	ModelMap temp = new ModelMap();
           	temp.put("sCode", rs2.getString(1));
           	temp.put("sDesc", rs2.getString(2));
           	model2.add(temp);
	        }
	        conn.close();   
	        
	        
	    	ModelMap temp = new ModelMap();
	    	temp.put("Proj", model);
	    	temp.put("WorkType", model2);
	    	
	    	modela.add(temp);
	    	
	    	conn.close();
	    } catch (Exception e) {
	        e.printStackTrace();
	    } 
	  
	    return modela;
	}
	
	public static List<Map<String, String>> getTasks(String pid) {
	    List<Map<String, String>> tasks = new ArrayList<>();
	    String sql = "SELECT TaskID, TaskDesc FROM ProjectTasks WHERE ProjectID = ?";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {

	        ps.setString(1, pid);
	        ResultSet rs = ps.executeQuery();

	        while (rs.next()) {
	            Map<String, String> task = new HashMap<>();
	            task.put("taskid", rs.getString("TaskID"));
	            task.put("taskdesc", rs.getString("TaskDesc"));
	            tasks.add(task);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return tasks;
	}

	
	public static int addEmpWS(Map<?, ?> woDetails) throws Exception {		
	    Map<?, ?> details = (Map<?, ?>) woDetails.get("Work");
	    ArrayList<Map<?, ?>> itemDetails = (ArrayList<Map<?, ?>>) woDetails.get("WorkItems");

	    taskid = DBQuery.getInt("SELECT ISNULL(MAX(WSID),0) + 1 FROM WorkSheetMaster WHERE EmpID = '" + details.get("empid") + "'", "", "", "");

	    PreparedStatement stmt = null;
	    Connection conn = null;

	    try {
	        String sql = "INSERT INTO WorkSheetMaster (WSID, EmpID, WSDate, WorkType, ProjectID, TaskID, TaskPercent, Description, Attachment, EntryDate) "
	                   + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

	        conn = ConnectionManager.getConnection();
	        stmt = conn.prepareStatement(sql);
	        stmt.setInt(1, taskid);
	        stmt.setString(2, details.get("empid").toString());
	        stmt.setString(3, details.get("wdate") == null || details.get("wdate").toString().isEmpty() ? null : details.get("wdate").toString());
	        stmt.setString(4, details.get("wtype").toString());
	        stmt.setString(5, details.get("pid").toString());
	        stmt.setString(6, details.get("tid") == null || details.get("tid").toString().isEmpty() || details.get("tid").equals("none") ? null : details.get("tid").toString());

	        stmt.setString(7, details.get("tper") == null || details.get("tper").toString().isEmpty() ? null : details.get("tper").toString());
	        
	        stmt.setString(8, details.get("desc").toString());
	        stmt.setString(9, details.get("attachment") == null ? null : details.get("attachment").toString());

	        stmt.executeUpdate();
	    } catch (SQLException e) {
	        e.printStackTrace();
	    } finally {
	        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
	        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
	    }

	    // Insert into WorkSheetDetail
	    try {
	        String sql = "INSERT INTO WorkSheetDetail (WSID, EmpID, Sno, TaskDesc, TaskReference, TimeStart, TimeEnd) VALUES (?, ?, ?, ?, ?, ?, ?)";
	        conn = ConnectionManager.getConnection();
	        PreparedStatement ps = conn.prepareStatement(sql);

	        // Fetch the current maximum Sno for the given WSID and EmpID
	        String maxSnoSql = "SELECT COALESCE(MAX(Sno), 0) FROM WorkSheetDetail WHERE WSID = ? AND EmpID = ?";
	        PreparedStatement maxSnoStmt = conn.prepareStatement(maxSnoSql);
	        maxSnoStmt.setInt(1, taskid); // Replace with your task ID
	        maxSnoStmt.setString(2, details.get("empid").toString()); // Replace with your employee ID
	        ResultSet maxSnoRs = maxSnoStmt.executeQuery();
	        int maxSno = 0;
	        if (maxSnoRs.next()) {
	            maxSno = maxSnoRs.getInt(1); // Get the highest existing Sno
	        }
	        maxSnoRs.close();
	        maxSnoStmt.close();

	        // Loop through each item and insert it with an incremented Sno
	        for (Map<?, ?> items : itemDetails) {
	            String sno = items.get("sno") == null || items.get("sno").toString().isEmpty() ? String.valueOf(maxSno + 1) : items.get("sno").toString();
	            maxSno++;  // Increment the Sno for each task

	            // Insert the task with the incremented Sno
	            ps.setInt(1, taskid);
	            ps.setString(2, details.get("empid").toString());
	            ps.setString(3, sno); // Use the incremented Sno
	            ps.setString(4, items.get("wdesc").toString());
	            ps.setString(5, items.get("wref") == null || items.get("wref").toString().isEmpty() ? null : items.get("wref").toString());
	            ps.setString(6, items.get("stime") == null || items.get("stime").toString().isEmpty() ? null : items.get("stime").toString());
	            ps.setString(7, items.get("etime") == null || items.get("etime").toString().isEmpty() ? null : items.get("etime").toString());

	            ps.addBatch(); // Add the task to the batch
	        }

	        // Execute the batch insert
	        ps.executeBatch();
	        ps.close();

	    } catch (SQLException e) {
	        e.printStackTrace(); // Handle exception
	    }

	     finally {
	        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
	    }
	    return taskid;
	}

	public static ArrayList<SpnTask> getSpnTask(String pid, String userid) {
        
		String sql = "SELECT TaskID,TaskDesc,dbo.GetParamDesc('TTY',TaskType),PercentComplete "
				+ " FROM ProjectTasks WHERE ProjectID = '" + pid + "' AND AssignedTo = '" + userid + "' AND TaskStatus IN ('O','P') ORDER BY TaskID ";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<SpnTask> items = new ArrayList<SpnTask>();       

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	items.add(new SpnTask(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4)));
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
        
        return items;
    }
	public static void updateWorksheetAttachment(String pid, String WSID, String taskid, String filename) throws Exception {
	    Connection con = ConnectionManager.getConnection();
	    String sql = "UPDATE WorkSheetMaster SET Attachment = ? WHERE (ProjectID = ? AND WSID = ?) AND (TaskID = ? OR (? IS NULL OR ? = ''))";

	    PreparedStatement ps = con.prepareStatement(sql);
	    ps.setString(1, filename);
	    ps.setString(2, pid);
	    ps.setString(3, WSID);

	    if (taskid == null || taskid.trim().isEmpty()) {
	        ps.setNull(4, java.sql.Types.INTEGER);
	        ps.setNull(5, java.sql.Types.INTEGER);
	        ps.setNull(6, java.sql.Types.VARCHAR);
	    } else {
	        ps.setInt(4, Integer.parseInt(taskid));
	        ps.setInt(5, Integer.parseInt(taskid));
	        ps.setString(6, taskid);
	    }

	    ps.executeUpdate();
	    con.close();
	}


	public static ArrayList<ModelMap> getWSList(String UserID, String WMonth, String WYear) {
        
        String sql = " SELECT DISTINCT CONVERT(VARCHAR,WSDate,106), WSDate " + 
        		" FROM WorkSheetMaster WHERE EmpID = '" + UserID + "' AND MONTH(WSDATE) = '" + WMonth + "' AND "
        		+ " YEAR(WSDATE) = '" + WYear + "' ORDER By WSDate DESC ";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<ModelMap> model = new ArrayList<ModelMap>();

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	ModelMap temp = new ModelMap();
            	temp.put("Title", rs.getString(1));
            	
            	String sql1 = "SELECT WSID,WSDate,dbo.GetParamDesc('WTY',WorkType),ProjectDesc + ' - ' + dbo.GetParamDesc('TEC',Technology), " + 
            			" ISNULL((SELECT TaskDesc FROM ProjectTasks WHERE ProjectID = A.ProjectID AND TaskID = A.TaskID),'') AS TDesc, "
            			+ " TaskID,TaskPercent,Description,EntryDate,ISNULL(Comments,'') "
            			+ " FROM WorkSheetMaster A, ProjectMaster B "
            			+ " WHERE A.ProjectID = B.ProjectID " +             		
            			" AND A.EmpID = '" + UserID + "' AND A.WSDate = '" + rs.getString(2) + "' ORDER BY A.TaskID ASC ";

                PreparedStatement pStmt1 = null;
                ResultSet rs1 = null;
                ArrayList<ModelMap> model1 = new ArrayList<ModelMap>();

                try {
                    conn = ConnectionManager.getConnection();
                    pStmt1 = conn.prepareStatement(sql1);
                    rs1 = pStmt1.executeQuery();

                    while (rs1.next()) {
                    	ModelMap temp1 = new ModelMap();
                    	temp1.put("wsid", rs1.getString(1));                  	
                    	temp1.put("wsdate", rs1.getString(2));      
                    	temp1.put("wtype", rs1.getString(3));                  	
                    	temp1.put("pdesc", rs1.getString(4));          
                    	temp1.put("tdesc", rs1.getString(5));                  	
                    	temp1.put("tid", rs1.getString(6));        
                    	temp1.put("tper", rs1.getString(7));        
                    	temp1.put("wdesc", rs1.getString(8));        
                    	temp1.put("edate", rs1.getString(9));        
                    	temp1.put("comm", rs1.getString(10));         
                    	model1.add(temp1);
                    }
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }          	
            	temp.put("Info", model1);
            	model.add(temp);
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
        System.out.print(model);
      
        return model;
    }	
	
	public static void deleteWS(String wsid, String empid) throws Exception {
        PreparedStatement stmt;
        try {      	
            String sql = "DELETE FROM WorkSheetMaster WHERE WSID = '" + wsid + "' AND EmpID = '" + empid + "'  ";
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
	public static ArrayList<ModelMap> getAccessibleEmployees(String empId) throws Exception {
	    PreparedStatement stmt;
	    ResultSet rs;
	    ArrayList<ModelMap> model = new ArrayList<>();

	    try {
	        // Step 1: Get ELevel of the given employee
	        String levelQuery = "SELECT ELevel FROM EmployeeMaster WHERE EmpID = ?";
	        conn = ConnectionManager.getConnection();
	        stmt = conn.prepareStatement(levelQuery);
	        stmt.setString(1, empId);
	        rs = stmt.executeQuery();

	        int eLevel = -1;
	        if (rs.next()) {
	            eLevel = rs.getInt("ELevel");
	        }
	        conn.close();

	        if (eLevel == -1) {
	            return model;
	        }

	        // Step 2: Get employees with ELevel >= current user's ELevel
	        String empQuery = "SELECT EmpID, EmpName FROM EmployeeMaster WHERE ELevel >= ?";
	        conn = ConnectionManager.getConnection();
	        stmt = conn.prepareStatement(empQuery);
	        stmt.setInt(1, eLevel); // ✅ Set the parameter here
	        rs = stmt.executeQuery();

	        while (rs.next()) {
	            ModelMap temp = new ModelMap();
	            temp.put("EmpID", rs.getString("EmpID"));
	            temp.put("EmpName", rs.getString("EmpName"));
	            model.add(temp);
	        }
	        conn.close();

	    } catch (SQLException e) {
	        e.printStackTrace();
	    }

	    System.out.println("Accessible Employees: " + model);
	    return model;
	}

	public static String getDOJOfEmployee(String selectedEmpId) throws Exception {
	    PreparedStatement stmt;
	    ResultSet rs;
	    String dojString = null;

	    try {
	        String sql = "SELECT DOJ FROM EmployeeMaster WHERE EmpID = ?";
	        conn = ConnectionManager.getConnection();
	        stmt = conn.prepareStatement(sql);
	        stmt.setString(1, selectedEmpId);
	        rs = stmt.executeQuery();

	        if (rs.next()) {
	            java.sql.Date dojDate = rs.getDate("DOJ");

	            if (dojDate != null) {
	                // Format as yyyy-MM-dd
	                dojString = dojDate.toLocalDate().toString();
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    } finally {
	        if (conn != null) {
	            conn.close();
	        }
	    }

	    System.out.println("Returning DOJ: " + dojString); // Optional: Debug log
	    return dojString;
	}


	
}
