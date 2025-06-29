package com.dbquest.dbq.service;

import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import com.dbquest.dbq.model.SpnCustom;
import com.dbquest.dbq.utils.ConnectionManager;

public class DBQuery {
	private static Connection conn = null;
	public static String getQuery(String sqlQuery, String param1, String param2, String param3) {
       
        PreparedStatement pStmt = null;
        ResultSet rs = null;
        String value = "";       

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sqlQuery);
            rs = pStmt.executeQuery();

            while (rs.next()) {            	
            	value = rs.getString(1);               
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
      
        return value;
    }
	
	public static Integer getInt(String sqlQuery, String param1, String param2, String param3) {
	       
        PreparedStatement pStmt = null;
        ResultSet rs = null;
        Integer value = null;       

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sqlQuery);
            rs = pStmt.executeQuery();

            while (rs.next()) {            	
            	value = rs.getInt(1);               
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
      
        return value;
    }
	
	public static ArrayList<SpnCustom> getSpinnerData(String sqlQuery) {       
		
        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<SpnCustom> spn = new ArrayList<SpnCustom>();       

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sqlQuery);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	spn.add(new SpnCustom(rs.getString(1),rs.getString(2)));
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
        
        return spn;
    }
	
	public static ArrayList<String> getSpinSingleData(String sqlQuery) {       
		
        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<String> spn = new ArrayList<String>();       

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sqlQuery);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	spn.add(rs.getString(1));
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
      
        return spn;
    }
	
	public static byte[] getBlob(String sqlQuery, String param1, String param2, String param3) {
	       
        PreparedStatement pStmt = null;
        ResultSet rs = null;
        byte[] photo = null;  

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sqlQuery);
            rs = pStmt.executeQuery();

            while (rs.next()) {   
            	Blob blob = rs.getBlob(1);
                byte[] blobAsBytes = null;

                if (blob != null) {
                    int blobLength = (int) blob.length();
                    blobAsBytes = blob.getBytes(1, blobLength);
                }      
                
                photo = blobAsBytes;
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
      
        return photo;
	}
	
}
