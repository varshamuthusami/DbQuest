package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBEmployee {

	private static Connection conn = null;	

public static ModelMap getEmpProfile(String empid) {
    
    String sql = "SELECT EmpName,ISNULL(Department,''),Designation,CONVERT(varchar,DOB,103),ISNULL(NativePlace,''),CONVERT(varchar,DOJ,103),MobileNo,Email \r\n" + 
    		" FROM EmployeeMaster " + 
    		" WHERE EmpID = '" + empid + "'";

    PreparedStatement pStmt = null;
    ResultSet rs = null;
    ModelMap model = new ModelMap();       

    try {
        conn = ConnectionManager.getConnection();
        pStmt = conn.prepareStatement(sql);
        rs = pStmt.executeQuery();

        while (rs.next()) {            	
            model.put("EmpName", rs.getString(1));
            model.put("Department", rs.getString(2));
            model.put("Designation", rs.getString(3));
            model.put("DOB", rs.getString(4));
            model.put("NativePlace", rs.getString(5));
            model.put("DOJ", rs.getString(6));
            model.put("Mobile", rs.getString(7));
            model.put("Email", rs.getString(8));
        }
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
  
    return model;
}	

public static void updateEmpApp(ModelMap details) throws Exception {
    PreparedStatement stmt;
    try {
        String sql ="UPDATE EmployeeMaster SET NativePlace = '" + details.get("NativePlace") + "', MobileNo = '" + details.get("Mobile") + "' "
        		+ " WHERE EmpID = '" +  details.get("EmpID") + "' ";
        conn = ConnectionManager.getConnection();
        stmt = conn.prepareStatement(sql);
        stmt.executeUpdate();
        conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    } 
}

}

