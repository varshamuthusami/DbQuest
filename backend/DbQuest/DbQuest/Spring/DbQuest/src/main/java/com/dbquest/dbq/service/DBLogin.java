package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBLogin {
	private static Connection conn = null;
	public static ModelMap getUserInfo(String uid, String pwd) {
        
        String sql = "SELECT UserID,UserName,Designation,Department, " +
                " Email,UserType,Token FROM Login " +
                " WHERE UserID = '" + uid + "' AND Password = '" + pwd + "' AND Active = 'A' ";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ModelMap model = new ModelMap();    
        Boolean validUser = false;

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	model.put("EmpID", rs.getString(1));
                model.put("EmpName", rs.getString(2));
                model.put("Designation", rs.getString(3));
                model.put("Department", rs.getString(4));
                model.put("EMailID", rs.getString(5));
                model.put("UType", rs.getString(6));
                model.put("Token", rs.getString(7));
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
	
	public static void updateToken(String token,String Uid,String type) throws Exception {
        PreparedStatement stmt;
        try {
            String sql ="";
            
            if(type.equals("E")) {
            	sql="update EmployeeMaster set Token='" +  token + "' where EmpID='" +  Uid + "'";
            }else {
            	sql="update CustomerContactMaster set Token='" +  token + "' where ConCode='" +  Uid + "'";
            }
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
	}
}
