package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBHome {
	
	private static Connection conn = null;

	public static ArrayList<ModelMap> genPendingTask(String UserID) {
	    
	    ArrayList<ModelMap> modela = new ArrayList<ModelMap>();
	 
	    	ModelMap temp = new ModelMap();
	    	
	    	temp.put("Task", DBProjTasks.getPendingTasks(UserID));
	    	temp.put("Leave", DBEmployeeLeave.getEmployeePending(UserID));
	    	temp.put("Chart", getWorksheetChart(UserID));
	    	    	
	    	modela.add(temp);
	    		  
	        return modela;
	}
	
	public static ArrayList<ModelMap> getWorksheetChart(String UserID) {
	    String sql = "SELECT wsm.ProjectID, pm.ProjectDesc, " +
	                 "       YEAR(wsm.WSDate) AS Year, " +
	                 "       MONTH(wsm.WSDate) AS Month, " +
	                 "       SUM(CASE " +
	                 "           WHEN wsd.TimeStart IS NULL OR wsd.TimeEnd IS NULL THEN 0 " +
	                 "           WHEN wsd.TimeStart > wsd.TimeEnd " +
	                 "               THEN DATEDIFF(MINUTE, wsd.TimeStart, DATEADD(DAY, 1, CAST(wsd.TimeEnd AS DATETIME))) " +
	                 "           ELSE DATEDIFF(MINUTE, wsd.TimeStart, wsd.TimeEnd) " +
	                 "       END) AS TotalDurationMinutes " +
	                 "FROM WorkSheetMaster wsm " +
	                 "JOIN WorkSheetDetail wsd ON wsm.WSID = wsd.WSID " +
	                 "JOIN ProjectMaster pm ON wsm.ProjectID = pm.ProjectID " +
	                 "WHERE wsm.EmpID = ? " +
	                 "GROUP BY wsm.ProjectID, pm.ProjectDesc, YEAR(wsm.WSDate), MONTH(wsm.WSDate) " +
	                 "ORDER BY Year DESC, Month DESC";  // Sorting by Year and Month

	    ArrayList<ModelMap> model = new ArrayList<>();
	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement pStmt = conn.prepareStatement(sql)) {

	        pStmt.setString(1, UserID);
	        ResultSet rs = pStmt.executeQuery();

	        while (rs.next()) {
	            ModelMap temp = new ModelMap();
	            temp.put("id", rs.getString(1));    
	            temp.put("desc", rs.getString(2));  
	            temp.put("year", rs.getInt(3));  
	            temp.put("month", rs.getInt(4));  
	            temp.put("value", rs.getString(5)); 
	            model.add(temp);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return model;
	}



}
