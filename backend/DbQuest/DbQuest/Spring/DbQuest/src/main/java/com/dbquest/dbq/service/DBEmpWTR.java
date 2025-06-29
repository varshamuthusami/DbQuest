package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBEmpWTR {
	private static Connection conn = null;
	public static ModelMap getTodayWtr(String uid) {
        
        String sql = "SELECT ISNULL(REPLACE(REPLACE(RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,StartTime,100),7)),7),'AM',' AM'),'PM',' PM'),''), "
        		+ " ISNULL(REPLACE(REPLACE(RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,EndTime,100),7)),7),'AM',' AM'),'PM',' PM'),'') FROM EmployeeAttendance " +                
                " WHERE Empid = '" + uid + "' AND WorkingDate = CONVERT(DATE,GETDATE()) ";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ModelMap model = new ModelMap();    
        Boolean validUser = false;

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
                model.put("In", rs.getString(1));
                model.put("Out", rs.getString(2));
                validUser = true;
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
    
        if (validUser) {
        	return model;
        } return null;
    }
	
	public static void addWtr(ModelMap details) throws Exception {
        PreparedStatement stmt;
        try {
            String sql = "INSERT INTO EmployeeWTR (EmpID,WTRTime,InOut) "
            		+ " VALUES ('" + details.get("empid") + "',getdate(),'" + details.get("type") + "') ";
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } 
    }
	
	public static void addWtrV1(ModelMap details) throws Exception {
        PreparedStatement stmt;
        try {
            String sql = "INSERT INTO EmployeeWTR (EmpID,WTRTime,InOut) "
            		+ " VALUES ('" + details.get("empid") + "',getdate(),'" + details.get("type") + "') ";
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } 
    }
	
	public static void deleteEmployeeWtr(String EmpID,String WType) throws Exception {		
        PreparedStatement stmt;        
        try {        	
            String sql="DELETE FROM EmployeeWTR WHERE EmpID ='" +  EmpID + "' AND CONVERT(DATE,WTRTime) = CONVERT(DATE,GETDATE()) AND InOut = '" +  WType + "'";
            
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } 
    }
	
	
	public static ArrayList<ModelMap> getEmpAttList(String UserID) {
        
        String sql = " SELECT DISTINCT DATENAME(Month, WorkingDate), DATENAME(Month, WorkingDate) + ' ' +  DATENAME(Year, WorkingDate) " + 
        		" FROM EmployeeAttendance  WHERE Empid = '" + UserID + "' ";

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
            	
            	String sql1 = "SELECT WorkingDate,RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, WorkingDate)), 2), DATENAME(dw,WorkingDate), ISNULL(REPLACE(REPLACE(RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,StartTime,100),7)),7),'AM',' AM'),'PM',' PM'),''),  " + 
            			" ISNULL(REPLACE(REPLACE(RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,EndTime,100),7)),7),'AM',' AM'),'PM',' PM'),''), " + 
            			" ISNULL(convert(varchar(5),DateDiff(s, [StartTime], [EndTime])/3600)+':'+convert(varchar(5),DateDiff(s, [StartTime], [EndTime])%3600/60),'') as [hh:mm:ss],'' AS Reason " + 
            			" FROM EmployeeAttendance " + 
            			" WHERE Empid = '" + UserID + "' AND DATENAME(Month, WorkingDate) = '" + rs.getString(1) + "' "
            					+ " UNION SELECT edate, RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, edate)), 2),DATENAME(dw,edate),'','','', " + 
            					"CASE Reason WHEN 'S' THEN 'Sick Leave' WHEN 'E' THEN 'Emergency Leave' " + 
            					"WHEN 'W' THEN 'Work from Home' WHEN 'O' THEN 'Others' ELSE '' END  " + 
            					"  FROM GetAllDays A, EmployeeLeave B " + 
            					"  WHERE edate BETWEEN FromDate AND ToDate AND DATENAME(w,edate) <> 'Sunday' AND "
            					+ " Empid = '" + UserID + "' AND DATENAME(Month, edate) = '" + rs.getString(1) + "' " + 
            					"  ORDER BY WorkingDate DESC";

                PreparedStatement pStmt1 = null;
                ResultSet rs1 = null;
                ArrayList<ModelMap> model1 = new ArrayList<ModelMap>();

                try {
                    conn = ConnectionManager.getConnection();
                    pStmt1 = conn.prepareStatement(sql1);
                    rs1 = pStmt1.executeQuery();

                    while (rs1.next()) {
                    	ModelMap temp1 = new ModelMap();
                    	temp1.put("date", rs1.getString(1));                  	
                    	temp1.put("day", rs1.getString(2));      
                    	temp1.put("name", rs1.getString(3));                  	
                    	temp1.put("in", rs1.getString(4));          
                    	temp1.put("out", rs1.getString(5));                  	
                    	temp1.put("hours", rs1.getString(6));      
                    	temp1.put("reason", rs1.getString(7));      
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
      
        return model;
    }	
	
	public static ArrayList<ModelMap> getEmpAttViewList(String UserID, String WMonth, String WYear) {
        
        String sql = " SELECT DISTINCT DATENAME(Month, WorkingDate), DATENAME(Month, WorkingDate) + ' ' +  DATENAME(Year, WorkingDate) " + 
        		" FROM EmployeeAttendance  WHERE Empid = '" + UserID + "' AND MONTH(WorkingDate) = '" + WMonth + "' AND YEAR(WorkingDate) = '" + WYear + "' ";

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
            	
            	String sql1 = "SELECT WorkingDate,RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, WorkingDate)), 2), DATENAME(dw,WorkingDate), ISNULL(REPLACE(REPLACE(RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,StartTime,100),7)),7),'AM',' AM'),'PM',' PM'),''),  " + 
            			" ISNULL(REPLACE(REPLACE(RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,EndTime,100),7)),7),'AM',' AM'),'PM',' PM'),''), " + 
            			" ISNULL(convert(varchar(5),DateDiff(s, [StartTime], [EndTime])/3600)+':'+convert(varchar(5),DateDiff(s, [StartTime], [EndTime])%3600/60),'') as [hh:mm:ss],'' AS Reason " + 
            			" FROM EmployeeAttendance " + 
            			" WHERE Empid = '" + UserID + "' AND DATENAME(Month, WorkingDate) = '" + rs.getString(1) + "' "
            					+ " UNION SELECT edate, RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, edate)), 2),DATENAME(dw,edate),'','','', " + 
            					"CASE Reason WHEN 'S' THEN 'Sick Leave' WHEN 'E' THEN 'Emergency Leave' " + 
            					"WHEN 'W' THEN 'Work from Home' WHEN 'O' THEN 'Others' ELSE '' END  " + 
            					"  FROM GetAllDays A, EmployeeLeave B " + 
            					"  WHERE edate BETWEEN FromDate AND ToDate AND DATENAME(w,edate) <> 'Sunday' AND "
            					+ " Empid = '" + UserID + "' AND DATENAME(Month, edate) = '" + rs.getString(1) + "' " + 
            					"  ORDER BY WorkingDate DESC";

                PreparedStatement pStmt1 = null;
                ResultSet rs1 = null;
                ArrayList<ModelMap> model1 = new ArrayList<ModelMap>();

                try {
                    conn = ConnectionManager.getConnection();
                    pStmt1 = conn.prepareStatement(sql1);
                    rs1 = pStmt1.executeQuery();

                    while (rs1.next()) {
                    	ModelMap temp1 = new ModelMap();
                    	temp1.put("date", rs1.getString(1));                  	
                    	temp1.put("day", rs1.getString(2));      
                    	temp1.put("name", rs1.getString(3));                  	
                    	temp1.put("in", rs1.getString(4));          
                    	temp1.put("out", rs1.getString(5));                  	
                    	temp1.put("hours", rs1.getString(6));      
                    	temp1.put("reason", rs1.getString(7));      
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
      
        return model;
    }	
}
