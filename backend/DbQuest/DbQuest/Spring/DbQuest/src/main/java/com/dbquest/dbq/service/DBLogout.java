package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBLogout {
	private static Connection conn = null;
	
	public static void setTokenNull(String uid) throws Exception {
        PreparedStatement stmt;
        try {
            String sql = "UPDATE EmployeeMaster Set Token = NULL,Device = NULL WHERE EmpID = '" + uid + "'";
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } 
    }

}
