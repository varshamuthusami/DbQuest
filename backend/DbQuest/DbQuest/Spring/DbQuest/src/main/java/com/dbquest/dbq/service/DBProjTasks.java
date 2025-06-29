package com.dbquest.dbq.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.UUID;

import org.json.JSONObject;
import org.springframework.ui.ModelMap;
import org.springframework.web.multipart.MultipartFile;

import com.dbquest.dbq.utils.ConnectionManager;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;



public class DBProjTasks {
	private static Connection conn = null;
	private static int taskid;
	//public final static String AUTH_KEY_FCM = "AAAAP9BoGO0:APA91bHglDdlAjix253UGpFsmA12kiyEPwqVQ3Ej3Bteyjq353EhV7rITDbjMxiBdUs8KK27hnYXXGMJxSEyBbbNWbJAlZSoboSt4PSR8xES79x9-83tBOz-Zihbq50MCQ9dSooN5Ej7";
	//public final static String API_URL_FCM = "https://fcm.googleapis.com/fcm/send";
	
	
	public static ArrayList<ModelMap> getProjTaskSpinnersData() {
	    
		 String sql = "SELECT ProjectID,ProjectDesc + ' - ' + ParamDesc FROM ProjectMaster A, Parameter B "
		 		+ " WHERE A.Technology = B.ParamID AND ParamType = 'TEC'";
		 
		 String sql1 = "SELECT EmpID,EmpName FROM EmployeeMaster WHERE Active = 'A' ORDER BY EmpID ";
		 
		 String sql2 = "SELECT ParamID,ParamDesc FROM Parameter WHERE ParamType = 'TTY'";
		 
	    PreparedStatement pStmt = null;
	    ResultSet rs = null;
	    ArrayList<ModelMap> model = new ArrayList<ModelMap>();

	    PreparedStatement pStmt1 = null;
	    ResultSet rs1 = null;
	    ArrayList<ModelMap> model1 = new ArrayList<ModelMap>();
	    
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
	        pStmt1 = conn.prepareStatement(sql1);
	        rs1 = pStmt1.executeQuery();

	        while (rs1.next()) {
	        	ModelMap temp = new ModelMap();
           	temp.put("sCode", rs1.getString(1));
           	temp.put("sDesc", rs1.getString(2));
           	model1.add(temp);
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
	    	temp.put("Assign", model1);
	    	temp.put("TaskType", model2);
	    	
	    	modela.add(temp);
	    	
	    	conn.close();
	    } catch (Exception e) {
	        e.printStackTrace();
	    } 
	  
	    return modela;
	}
	
	
	public static void addProjTasks(ModelMap details, MultipartFile file) throws Exception {
	    taskid = DBQuery.getInt(
	        "SELECT ISNULL(MAX(TaskID), 0) + 1 FROM ProjectTasks WHERE ProjectID = '" + details.get("pid") + "'",
	        "", "", ""
	    );

	    String attachmentName = null;

	    // Upload file if provided
	    if (file != null && !file.isEmpty()) {
	        String UPLOAD_FOLDER = "D:\\varsha\\projects";
	        String pid = details.get("pid").toString();
	        String taskIdStr = String.valueOf(taskid);
	        String fileName = file.getOriginalFilename();

	        String folderPath = UPLOAD_FOLDER + File.separator + pid + File.separator + taskIdStr;
	        File directory = new File(folderPath);
	        if (!directory.exists()) {
	            boolean created = directory.mkdirs();
	            if (!created) {
	                throw new IOException("Failed to create directories");
	            }
	        }

	        File savedFile = new File(folderPath + File.separator + fileName);
	        try (FileOutputStream fout = new FileOutputStream(savedFile)) {
	            fout.write(file.getBytes());
	            attachmentName = fileName;
	        }
	    }

	    // Insert task into DB
	    String sql = "INSERT INTO ProjectTasks (ProjectID, TaskID, TaskType, TaskDesc, ESDate, EFDate, CreatedBy, AssignedTo, Attachment) " +
	                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

	    try (Connection conn = ConnectionManager.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
	        stmt.setString(1, details.get("pid").toString());
	        stmt.setInt(2, taskid);
	        stmt.setString(3, details.get("ttype").toString());
	        stmt.setString(4, details.get("tdesc").toString().isEmpty() ? null : details.get("tdesc").toString());
	        stmt.setString(5, details.get("sdate").toString().isEmpty() ? null : details.get("sdate").toString());
	        stmt.setString(6, details.get("edate").toString().isEmpty() ? null : details.get("edate").toString());
	        stmt.setString(7, details.get("cby").toString());
	        stmt.setString(8, details.get("ato").toString());
	        stmt.setString(9, attachmentName);
	        stmt.executeUpdate();
	    }

        gettoken(details.get("ato").toString(),details.get("cby").toString(),
        		details.get("ttype").toString(),details.get("tdesc").toString());
    }
	
	public static void updateProjTasks(ModelMap details, MultipartFile file) throws Exception {
	    PreparedStatement stmt = null;
	    Connection conn = null;

	    boolean hasFile = file != null && !file.isEmpty();

	    try {
	        conn = ConnectionManager.getConnection();

	        // 1) Build main UPDATE (metadata + optional placeholder for Attachment)
	        StringBuilder sql = new StringBuilder(
	            "UPDATE ProjectTasks SET TaskType=?, TaskDesc=?, ESDate=?, EFDate=?, AssignedTo=?"
	        );
	        if (hasFile) {
	            sql.append(", Attachment=?");
	        }
	        sql.append(" WHERE ProjectID=? AND TaskID=?");
	        System.out.println("Generated SQL: " + sql);

	        stmt = conn.prepareStatement(sql.toString());

	        // 2) Bind metadata fields
	        stmt.setString(1, toNullableString(details.get("ttype")));
	        stmt.setString(2, toNullableString(details.get("tdesc")));
	        stmt.setString(3, toNullableString(details.get("sdate")));
	        stmt.setString(4, toNullableString(details.get("edate")));
	        stmt.setString(5, toNullableString(details.get("ato")));

	        int paramIndex = 6;

	        // 3) If there is a file, bind a dummy placeholder so the SQL stays valid
	        if (hasFile) {
	            stmt.setString(paramIndex++, "");  
	        }

	        // 4) Bind ProjectID & TaskID
	        int pid = Integer.parseInt(details.get("pid").toString().trim());
	        int tid = Integer.parseInt(details.get("tid").toString().trim());
	        stmt.setInt(paramIndex++, pid);
	        stmt.setInt(paramIndex, tid);

	        // 5) Execute metadata update
	        int rowsUpdated = stmt.executeUpdate();
	        System.out.println("Rows updated: " + rowsUpdated);

	        // 6) Only if a file was provided AND the row existed, save & then update filename
	        if (hasFile && rowsUpdated > 0) {
	            String uploadDir = "uploads/project_" + pid + "/task_" + tid;
	            File dir = new File(uploadDir);
	            if (!dir.exists()) dir.mkdirs();

	            // Use original filename
	            String fileName = file.getOriginalFilename();
	            Path filePath = Paths.get(uploadDir, fileName);

	            // Overwrite any existing file
	            File existing = filePath.toFile();
	            if (existing.exists()) existing.delete();

	            // Save the file to disk
	            file.transferTo(filePath);
	            System.out.println("File saved to: " + filePath);

	            // 7) Update DB with filename only
	            String updateAttachmentSQL =
	                "UPDATE ProjectTasks SET Attachment = ? WHERE ProjectID = ? AND TaskID = ?";
	            try (PreparedStatement updateStmt = conn.prepareStatement(updateAttachmentSQL)) {
	                updateStmt.setString(1, fileName);  // ← store only the filename
	                updateStmt.setInt   (2, pid);
	                updateStmt.setInt   (3, tid);
	                int attRows = updateStmt.executeUpdate();
	                System.out.println("Attachment filename updated in DB, rows: " + attRows);
	            }
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();
	        throw new RuntimeException("Error updating ProjectTask", e);
	    } finally {
	        if (stmt != null) stmt.close();
	        if (conn != null) conn.close();
	    }
	}
	
	
	 public static void deleteProjectTask(String pid, String taskid) throws Exception {
		    PreparedStatement stmt = null;
		    Connection conn = null;
		    ResultSet rs = null;

		    try {
		        conn = ConnectionManager.getConnection();

		        // Step 1: Fetch the attachment filename for the task (if any)
		        String fetchSql = "SELECT Attachment FROM ProjectTasks WHERE ProjectID = ? AND TaskID = ?";
		        stmt = conn.prepareStatement(fetchSql);
		        stmt.setInt(1, Integer.parseInt(pid.trim()));
		        stmt.setInt(2, Integer.parseInt(taskid.trim()));
		        rs = stmt.executeQuery();

		        String fileName = null;
		        if (rs.next()) {
		            fileName = rs.getString("Attachment");
		        }

		        // Step 2: Delete the file from disk (if filename exists)
		        if (fileName != null && !fileName.isEmpty()) {
		            String uploadDir = "uploads/project_" + pid + "/task_" + taskid;
		            File file = new File(uploadDir, fileName);
		            if (file.exists()) {
		                boolean deleted = file.delete();
		                System.out.println("File " + file.getAbsolutePath() + " deleted: " + deleted);
		            }
		        }

		        // Step 3: Delete the task from the table
		        String deleteSql = "DELETE FROM ProjectTasks WHERE ProjectID = ? AND TaskID = ?";
		        stmt = conn.prepareStatement(deleteSql);
		        stmt.setInt(1, Integer.parseInt(pid.trim()));
		        stmt.setInt(2, Integer.parseInt(taskid.trim()));
		        int rows = stmt.executeUpdate();
		        System.out.println("Task deleted: " + rows + " row(s)");

		    } catch (SQLException e) {
		        e.printStackTrace();
		        throw new RuntimeException("Error deleting project task", e);
		    } finally {
		        if (rs != null) rs.close();
		        if (stmt != null) stmt.close();
		        if (conn != null) conn.close();
		    }
		}

		

	// Helper to convert blank or missing values to null
	private static String toNullableString(Object val) {
	    return (val != null && !val.toString().trim().isEmpty())
	        ? val.toString().trim()
	        : null;
	}
 
	
	
	
	public static ArrayList<ModelMap> getProjTaskList(String UserID) {
        
        String sql = " SELECT DISTINCT A.ProjectID,B.ProjectDesc + ' - ' + dbo.GetParamDesc('TEC',Technology) " + 
        		" FROM ProjectTasks A, ProjectMaster B WHERE A.ProjectID = B.ProjectID  AND A.CreatedBy = '" + UserID + "' ORDER By A.ProjectID ";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<ModelMap> model = new ArrayList<ModelMap>();

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	ModelMap temp = new ModelMap();
            	temp.put("Title", rs.getString(2));
            	
            	String sql1 = "SELECT A.ProjectID,B.ProjectDesc + ' - ' + dbo.GetParamDesc('TEC',Technology) " + 
            			" ,TaskID,row_number() over (order by TaskID),dbo.GetParamDesc('TTY',TaskType) "
            			+ " ,TaskDesc,CONVERT(VARCHAR,ESDate,105),CONVERT(VARCHAR,EFDate,105),Duration "
            			+ " ,AssignedTo,EmpName,dbo.GetParamDesc('STS',TaskStatus),PercentComplete,Attachment "
            			+ " FROM ProjectTasks A, ProjectMaster B, EmployeeMaster C "
            			+ " WHERE A.ProjectID = B.ProjectID AND A.AssignedTo = C.EmpID " +             		
            			" AND A.CreatedBy = '" + UserID + "' AND A.ProjectID = '" + rs.getString(1) + "' ORDER BY TaskID ASC ";

                PreparedStatement pStmt1 = null;
                ResultSet rs1 = null;
                ArrayList<ModelMap> model1 = new ArrayList<ModelMap>();

                try {
                    conn = ConnectionManager.getConnection();
                    pStmt1 = conn.prepareStatement(sql1);
                    rs1 = pStmt1.executeQuery();

                    while (rs1.next()) {
                    	ModelMap temp1 = new ModelMap();
                    	temp1.put("pid", rs1.getString(1));                  	
                    	temp1.put("pdesc", rs1.getString(2));      
                    	temp1.put("tid", rs1.getString(3));                  	
                    	temp1.put("sno", rs1.getString(4));          
                    	temp1.put("ttype", rs1.getString(5));                  	
                    	temp1.put("tdesc", rs1.getString(6));        
                    	temp1.put("sdate", rs1.getString(7));        
                    	temp1.put("edate", rs1.getString(8));        
                    	temp1.put("dura", rs1.getString(9));        
                    	temp1.put("assgid", rs1.getString(10));        
                    	temp1.put("assgname", rs1.getString(11));        
                    	temp1.put("status", rs1.getString(12));        
                    	temp1.put("percent", rs1.getString(13));     
                    	temp1.put("attachment", rs1.getString(14));   
                    	model1.add(temp1);
                    }
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }          	
            	temp.put("Info", model1);
            	model.add(temp);
            	System.out.print(model);
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
      
        return model;
    }	
	
	public static ArrayList<ModelMap> getprojecttaskbasedElevel(String empId) {
	    ArrayList<ModelMap> model = new ArrayList<ModelMap>();
	    PreparedStatement pStmt = null;
	    ResultSet rs = null;

	    try {
	        // Step 1: Get accessible employee IDs
	        ArrayList<ModelMap> accessibleEmps = DBEmpWS.getAccessibleEmployees(empId);
	        if (accessibleEmps.isEmpty()) {
	            return model;
	        }

	        // Step 2: Create IN clause for query
	        StringBuilder empIdList = new StringBuilder();
	        for (ModelMap m : accessibleEmps) {
	            if (empIdList.length() > 0) empIdList.append(",");
	            empIdList.append("'").append(m.get("EmpID")).append("'");
	        }

	        // Step 3: Build SQL with IN clause
	        String sql = "SELECT TaskID, " +
	                "(SELECT ParamDesc FROM Parameter WHERE ParamType='TTY' AND ParamID=TaskType), " +
	                "TaskDesc, CONVERT(varchar, ESDate, 103), CONVERT(varchar, EFDate, 103), " +
	                "Duration, (SELECT ParamDesc FROM Parameter WHERE ParamType='STS' AND ParamID=TaskStatus), " +
	                "PercentComplete, AssignedTo, (SELECT EmpName FROM EmployeeMaster WHERE EmpID=AssignedTo), " +
	                "Remarks, ProjectID, Attachment, TaskType, TaskStatus " +
	                "FROM ProjectTasks " +
	                "WHERE AssignedTo IN (" + empIdList.toString() + ")";

	        conn = ConnectionManager.getConnection();
	        pStmt = conn.prepareStatement(sql);
	        rs = pStmt.executeQuery();

	        while (rs.next()) {
	            ModelMap temp = new ModelMap();
	            temp.put("taskid", rs.getString(1));
	            temp.put("tasktype", rs.getString(2));
	            temp.put("taskdesc", rs.getString(3));
	            temp.put("sdate", rs.getString(4));
	            temp.put("edate", rs.getString(5));
	            temp.put("duration", rs.getString(6));
	            temp.put("taskstatus", rs.getString(7));
	            temp.put("percent", rs.getString(8));
	            temp.put("ato", rs.getString(9));
	            temp.put("aname", rs.getString(10));
	            temp.put("remark", rs.getString(11));
	            temp.put("pid", rs.getString(12));
	            temp.put("attachment", rs.getString(13));
	            temp.put("ntasktype", rs.getString(14));
	            temp.put("status", rs.getString(15));
	            model.add(temp);
	        }
	        conn.close();

	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return model;
	}
	
	public static ArrayList<ModelMap> getprojecttask() {
        
        String sql = "  select TaskID,(select ParamDesc from Parameter where ParamType='TTY' and ParamID=TaskType),\r\n" + 
        		"  TaskDesc,CONVERT(varchar, ESDate, 103),CONVERT(varchar, EFDate, 103),\r\n" + 
        		"  Duration,(select ParamDesc from Parameter where ParamType='STS' and ParamID=TaskStatus),\r\n" + 
        		"  PercentComplete,AssignedTo,(select EmpName from EmployeeMaster where EmpID=AssignedTo),\r\n" + 
        		"  Remarks,ProjectID,Attachment,TaskType,TaskStatus\r\n" + 
        		"  from ProjectTasks";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<ModelMap> model = new ArrayList<ModelMap>();

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	ModelMap temp = new ModelMap();
            	temp.put("taskid", rs.getString(1));
              	temp.put("tasktype", rs.getString(2));
            	temp.put("taskdesc", rs.getString(3));
            	temp.put("sdate", rs.getString(4));
            	temp.put("edate", rs.getString(5));
            	temp.put("duration", rs.getString(6));
            	temp.put("taskstatus", rs.getString(7));
            	temp.put("percent", rs.getString(8));
            	temp.put("ato", rs.getString(9));
            	temp.put("aname", rs.getString(10));
            	temp.put("remark", rs.getString(11));
            	temp.put("pid", rs.getString(12));
            	temp.put("attachment", rs.getString(13));
            	temp.put("ntasktype", rs.getString(14));
             	temp.put("status", rs.getString(15));
            	model.add(temp);
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
        return model;
    }	
	public static ArrayList<ModelMap> getPendingTasks(String UserID) {
	    String sql = "SELECT "
	            + "  ProjectID,"
	            + "  TaskID,"
	            + "  TaskDesc,"
	            + "  ESDate,"
	            + "  EFDate,"
	            + "  TaskStatus,"
	            + "  PercentComplete "
	            + "FROM ProjectTasks "
	            + "WHERE AssignedTo = '" + UserID + "' "
	            + "AND TaskStatus = 'P'";  // Only fetching pending tasks
	    
	    PreparedStatement pStmt = null;
	    ResultSet rs = null;
	    ArrayList<ModelMap> model = new ArrayList<ModelMap>();

	    try {
	        conn = ConnectionManager.getConnection();  // Make sure connection is correct
	        pStmt = conn.prepareStatement(sql);
	        rs = pStmt.executeQuery();

	        // Iterate over the results and add each task to the model
	        while (rs.next()) {
	            ModelMap temp = new ModelMap();
	            temp.put("Title", rs.getString("TaskDesc"));  // Task description

	            // Create another list for task details (this might not be needed if you want just the task list)
	            ArrayList<ModelMap> model1 = new ArrayList<ModelMap>();
	            ModelMap temp1 = new ModelMap();
	            temp1.put("pid", rs.getString("ProjectID"));  // Project ID
	            temp1.put("tid", rs.getString("TaskID"));  // Task ID
	            temp1.put("tdesc", rs.getString("TaskDesc"));  // Task Description
	            temp1.put("sdate", rs.getString("ESDate"));  // Start Date
	            temp1.put("edate", rs.getString("EFDate"));  // End Date
	            temp1.put("status", rs.getString("TaskStatus"));  // Task Status
	            temp1.put("percent", rs.getString("PercentComplete"));  // Percent Completed

	            model1.add(temp1);
	            temp.put("Info", model1);  // Add task details to the "Info" key
	            model.add(temp);  // Add task model to the main list
	        }
	        conn.close();  // Ensure connection is closed after query execution
	    } catch (Exception e) {
	        e.printStackTrace();  // Print the exception if any
	    }

	    return model;  // Return the list of tasks
	}
	public static ArrayList<ModelMap> getTasksByEmpIdAndProjectId(String UserID, String projectID) {
	    String sql = "SELECT " +
	            "  WSID, " +
	            "  EmpID, " +
	            "  WSDate, " +
	            "  WorkType, " +
	            "  ProjectID, " +
	            "  TaskID, " +
	            "  TaskPercent, " +
	            "  Description, " +
	            "  EntryDate, " +
	            "  Comments " +
	            "FROM WorkSheetMaster " +
	            "WHERE EmpID = ? AND ProjectID = ?";  // Filtering by both EmpID and ProjectID

	    ArrayList<ModelMap> taskList = new ArrayList<>();
	    PreparedStatement pStmt = null;
	    ResultSet rs = null;

	    try {
	        Connection conn = ConnectionManager.getConnection();  // Get DB connection
	        pStmt = conn.prepareStatement(sql);
	        pStmt.setString(1, UserID);      // Set EmpID parameter
	        pStmt.setString(2, projectID);  // Set ProjectID parameter
	        rs = pStmt.executeQuery();

	        while (rs.next()) {
	            ModelMap task = new ModelMap();
	            task.put("WSID", rs.getString("WSID"));
	            task.put("EmpID", rs.getString("EmpID"));
	            task.put("WSDate", rs.getString("WSDate"));
	            task.put("WorkType", rs.getString("WorkType"));
	            task.put("ProjectID", rs.getString("ProjectID"));
	            task.put("TaskID", rs.getString("TaskID"));
	            task.put("TaskPercent", rs.getString("TaskPercent"));
	            task.put("Description", rs.getString("Description"));
	            task.put("EntryDate", rs.getString("EntryDate"));
	            task.put("Comments", rs.getString("Comments"));

	            taskList.add(task);
	        }

	        conn.close();  // Close connection properly
	    } catch (Exception e) {
	        e.printStackTrace();  // Print the exception for debugging
	    }

	    return taskList;
	}


	
	
	  public static void updateprojecttask(String pid,String taskid,String filename) throws Exception {
	        PreparedStatement stmt;
	        try {
	            String sql = "UPDATE ProjectTasks SET Attachment = '" + filename  + "' "
	            		+ " WHERE ProjectID = '" +  pid + "' and TaskID = '" +  taskid + "' ";
	            conn = ConnectionManager.getConnection();
	            stmt = conn.prepareStatement(sql);
	            int rows = stmt.executeUpdate();
	            System.out.println("Rows updated: " + rows);

	            if (rows == 0) {
	                System.err.println("❗ No matching task found in DB for given PID and TASKID");
	            }
	            System.out.println("Updating DB with pid=" + pid + ", taskid=" + taskid + ", filename=" + filename);

	            conn.close();
	        } catch (SQLException e) {
	            e.printStackTrace();
	        } 
	    }
	  
	  
	 
		
		public static ArrayList<ModelMap> getProjList(String UserId) {
	        
	        String sql = "  SELECT A.ProjectID,B.ProjectDesc + ' - ' + dbo.GetParamDesc('TEC',Technology),\r\n" + 
	        		"  TaskID,row_number() over (order by TaskID),dbo.GetParamDesc('TTY',TaskType),\r\n" + 
	        		"  TaskDesc,CONVERT(VARCHAR,ESDate,105),CONVERT(VARCHAR,EFDate,105),Duration,\r\n" + 
	        		"  AssignedTo,EmpName,dbo.GetParamDesc('STS',TaskStatus),PercentComplete,Attachment \r\n" + 
	        		"  FROM ProjectTasks A, ProjectMaster B, EmployeeMaster C WHERE A.ProjectID = B.ProjectID AND \r\n" + 
	        		"  A.AssignedTo = C.EmpID AND A.AssignedTo = '" + UserId + "'  ORDER BY TaskID ASC";

	        PreparedStatement pStmt = null;
	        ResultSet rs = null;
	        ArrayList<ModelMap> model = new ArrayList<ModelMap>();

	        try {
	            conn = ConnectionManager.getConnection();
	            pStmt = conn.prepareStatement(sql);
	            rs = pStmt.executeQuery();

	            while (rs.next()) {
	            	ModelMap temp = new ModelMap();
	            	temp.put("pid", rs.getString(1));                  	
	            	temp.put("pdesc", rs.getString(2));      
	            	temp.put("tid", rs.getString(3));                  	
	            	temp.put("sno", rs.getString(4));          
	            	temp.put("ttype", rs.getString(5));                  	
	            	temp.put("tdesc", rs.getString(6));        
	            	temp.put("sdate", rs.getString(7));        
	            	temp.put("edate", rs.getString(8));        
	            	temp.put("dura", rs.getString(9));        
	            	temp.put("assgid", rs.getString(10));        
	            	temp.put("assgname", rs.getString(11));        
	            	temp.put("status", rs.getString(12));        
	            	temp.put("percent", rs.getString(13));    
	            	temp.put("attachment", rs.getString(14));   
	            	model.add(temp);
	            }
	            conn.close();
	        } catch (Exception e) {
	            e.printStackTrace();
	        } 
	      
	        return model;
	    }
		public static String saveFcmToken(String empId, String fcmtoken) {
		    String query = "UPDATE EmployeeMaster SET Token = ? WHERE EmpID = ?";
		    try (Connection conn = ConnectionManager.getConnection();
		         PreparedStatement stmt = conn.prepareStatement(query)) {

		        stmt.setString(1, fcmtoken);
		        stmt.setString(2, empId);

		        int rowsUpdated = stmt.executeUpdate();
		        return rowsUpdated > 0 ? "Token saved successfully!" : "User not found";

		    } catch (Exception e) {
		        e.printStackTrace();
		        return "Error saving token";
		    }
		}
		
		
		public static void gettoken(String id,String by,String ptype,String desc) {

			   String token="";
			   String name="";
			   String content="";
			   
			   String sqlQuery="select Token,(select UserID+' - '+UserName from Login where UserID='" + by + "'),\r\n" + 
			   		"  (select ParamDesc from Parameter where ParamType='TTY' and ParamID='" + ptype + "')\r\n" + 
			   		"  from Login where UserID='" + id + "'";
			   
			   PreparedStatement pStmt = null;
		       ResultSet rs = null;
		    
		       try {
		           conn = ConnectionManager.getConnection();
		           pStmt = conn.prepareStatement(sqlQuery);
		           rs = pStmt.executeQuery();

		           while (rs.next()) {            	
		        	   token = rs.getString(1);
		        	   if (token == null || token.trim().isEmpty()) {
		        		    System.err.println("Device token is null or empty — skipping FCM push");
		        		    return;
		        		}
		        	   name = rs.getString(2);
		        	   content= rs.getString(3)+" - "+desc;
		           }
		           conn.close();
		       } catch (Exception e) {
		           e.printStackTrace();
		       } 
		     
		       System.out.println(token);
			   
			//FCMService.sendNotification(token,name,content);
		       sendPushNotificationNew(token, name, content);

		   }
			
		public static String sendPushNotificationNew(String deviceToken, String title, String body) {
		    try {
		        Message message = Message.builder()
		            .setToken(deviceToken.trim())
		            .setNotification(Notification.builder()
		                .setTitle(title)
		                .setBody(body)
		                .build())
		            .build();

		        String response = FirebaseMessaging.getInstance().send(message);
		        System.out.println("Successfully sent message: " + response);
		        return "SUCCESS";
		    } catch (Exception e) {
		        e.printStackTrace();
		        return "FAILURE";
		    }
		}

}
