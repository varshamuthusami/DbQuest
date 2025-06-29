package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.springframework.ui.ModelMap;
import java.util.Random;
import java.sql.Timestamp;


import com.dbquest.dbq.utils.ConnectionManager;
import com.dbquest.dbq.utils.EmailUtil;

public class DBChangePassword {
	
	private static Connection conn = null;	
	
	public static ModelMap getCurrentPass(String UserID) {		
        
        String sql = "select Password from Login where UserID = '" + UserID + "'";
        
        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ModelMap model = new ModelMap();       

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {            	
                model.put("CurrentPassword", rs.getString(1));
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }       
      
        return model;
    }	

	
	public static void updatePassword(ModelMap details) throws Exception {
	    PreparedStatement stmt;
	    String sql = "";
	    try {
	    	if (details.get("UType").toString().equals("E")) {
	    		sql ="UPDATE EmployeeMaster SET Password = '" + details.get("Pwd") + "'"
		        		+ " WHERE EmpID = '" + details.get("UserID") + "' ";
	    	}else if (details.get("UType").toString().equals("C")) {
	    		sql ="UPDATE CustomerContactMaster SET Password = '" + details.get("Pwd") + "'"
		        		+ " WHERE ConCode = '" + details.get("UserID") + "' ";
	    	}
	        
	        conn = ConnectionManager.getConnection();
	        stmt = conn.prepareStatement(sql);
	        stmt.executeUpdate();
	        conn.close();
	    } catch (SQLException e) {
	        e.printStackTrace();
	    } 
	}
	
	public static boolean generateAndSendOtp(String email) {
	    
		System.out.println("entered otp generation method");
	    PreparedStatement stmt = null;
	    try {
	        // 1. Check if email exists
	        String checkSql = "SELECT EmpID FROM EmployeeMaster WHERE Email = ?";
	        conn = ConnectionManager.getConnection();
	        stmt = conn.prepareStatement(checkSql);
	        stmt.setString(1, email);
	        ResultSet rs = stmt.executeQuery();

	        if (!rs.next()) {
	            return false; // email not found
	        }

	        String empId = rs.getString("EmpID");
	        System.out.println(empId);

	        // 2. Generate OTP
	        String otp = String.format("%06d", new Random().nextInt(999999));
	        Timestamp now = new Timestamp(System.currentTimeMillis());

	        // 3. Update OTP and time
	        String updateSql = "UPDATE EmployeeMaster SET Otp = ?, OtpTime = ? WHERE EmpID = ?";
	        stmt = conn.prepareStatement(updateSql);
	        stmt.setString(1, otp);
	        stmt.setTimestamp(2, now);
	        stmt.setString(3, empId);
	        stmt.executeUpdate();

	        // 4. Send email (implement sendEmail separately)
	        String subject = "Your OTP for Password Reset";
	        String body = "Your OTP is: " + otp + "\nIt is valid for 10 minutes.";
	        EmailUtil.sendEmail(email, subject, body);

	        return true;
	    } catch (Exception e) {
	        e.printStackTrace();
	        return false;
	    } finally {
	        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
	        try { if (conn != null) conn.close(); } catch (Exception e) {}
	    }
	}

	public static boolean verifyAndResetPassword(String email, String enteredOtp, String newPassword) {
	    
	    PreparedStatement stmt = null;
	    ResultSet rs = null;

	    try {
	        conn = ConnectionManager.getConnection();

	        // 1. Fetch OTP and timestamp
	        String selectSql = "SELECT Otp, OtpTime FROM EmployeeMaster WHERE Email = ?";
	        stmt = conn.prepareStatement(selectSql);
	        stmt.setString(1, email);
	        rs = stmt.executeQuery();

	        if (!rs.next()) {
	            return false;
	        }

	        String dbOtp = rs.getString("Otp");
	        Timestamp otpTime = rs.getTimestamp("OtpTime");

	        // 2. Validate OTP
	        if (dbOtp == null || !dbOtp.equals(enteredOtp)) {
	            return false;
	        }

	        // 3. Check expiry (10 minutes)
	        long diffInMinutes = (System.currentTimeMillis() - otpTime.getTime()) / (60 * 1000);
	        if (diffInMinutes > 10) {
	            return false;
	        }

	        // 4. OTP is valid, so reset password
	        String updateSql = "UPDATE EmployeeMaster SET Password = ?, Otp = NULL, OtpTime = NULL WHERE Email = ?";
	        stmt = conn.prepareStatement(updateSql);
	        stmt.setString(1, newPassword);
	        stmt.setString(2, email);
	        int rows = stmt.executeUpdate();

	        return rows > 0;

	    } catch (Exception e) {
	        e.printStackTrace();
	        return false;
	    } finally {
	        try { if (rs != null) rs.close(); } catch (Exception e) {}
	        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
	        try { if (conn != null) conn.close(); } catch (Exception e) {}
	    }
	}

}
