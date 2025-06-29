package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBEmpToken {
    private static Connection conn = null;

    public static boolean saveToken(String empId, String token) throws Exception {
        String sql = "INSERT INTO EmployeeTokens (EmpId, Token) VALUES (?, ?)";
        PreparedStatement pStmt = null;

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            pStmt.setString(1, empId);
            pStmt.setString(2, token);
            
            int rowsInserted = pStmt.executeUpdate();
            conn.close();
            return rowsInserted > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static String getToken(String empId) throws Exception {
        String sql = "SELECT Token FROM EmployeeTokens WHERE EmpId = ?";
        PreparedStatement pStmt = null;
        ResultSet rs = null;
        String token = null;

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            pStmt.setString(1, empId);
            rs = pStmt.executeQuery();

            if (rs.next()) {
                token = rs.getString(1);
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return token;
    }
}
