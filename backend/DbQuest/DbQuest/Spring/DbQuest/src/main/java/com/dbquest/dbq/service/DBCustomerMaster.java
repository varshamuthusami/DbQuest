package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.DataTruncation;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBCustomerMaster {

	private static Connection conn = null;
	
	public static ArrayList<ModelMap> getCustomerMaster() {
		
        String sql = "select CusCode,CusName,Address1,Address2,Address3,Address4,isnull(Phone,''),isnull(Email,''),isnull(HomePage,''), " + 
        		"  isnull(Country,''),Status,isnull(VATNo,'') from CustomerMaster";

        PreparedStatement pStmt = null;
        ResultSet rs = null;
        ArrayList<ModelMap> model = new ArrayList<ModelMap>();

        try {
            conn = ConnectionManager.getConnection();
            pStmt = conn.prepareStatement(sql);
            rs = pStmt.executeQuery();

            while (rs.next()) {
            	ModelMap temp = new ModelMap();
            	temp.put("cuscode", rs.getString(1));
              	temp.put("cusname", rs.getString(2));
            	temp.put("add1", rs.getString(3));
            	temp.put("add2", rs.getString(4));
            	temp.put("add3", rs.getString(5));
            	temp.put("add4", rs.getString(6));
            	temp.put("phone", rs.getString(7));
            	temp.put("email", rs.getString(8));
            	temp.put("web", rs.getString(9));
            	temp.put("country", rs.getString(10));
            	temp.put("status", rs.getString(11));
            	temp.put("vatno", rs.getString(12));

            	model.add(temp);
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        } 
      System.out.print(model);
        return model;
    }	

	public static void addCustomerMaster(ModelMap details) throws Exception {	
		
        PreparedStatement stmt;
        try {
        	
            String sql = "INSERT INTO CustomerMaster (CusCode,CusName,Address1,Address2,Address3,Address4,Phone,Email,HomePage,Country,Status) "
            		+ " VALUES (?,?,'" + details.get("add1") + "','" + details.get("add2") +"', "
            		+ " '" + details.get("add3") + "','" + details.get("add4") + "','" + details.get("phone") + "' "
            				+ ",'" + details.get("email") + "','" + details.get("web") + "','" + details.get("country") + "','" + details.get("status") + "') ";
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, (details.get("cuscode").toString().equals("")?null:details.get("cuscode").toString()));
            stmt.setString(2, (details.get("cusname").toString().equals("")?null:details.get("cusname").toString()));

            stmt.executeUpdate();
            
        } catch (SQLException e) {
        	
          e.printStackTrace();
          
        } 
        
    }

	public static void updateCustomerMaster(ModelMap details) throws Exception {
		
        PreparedStatement stmt;
        try {    
            String sql="update CustomerMaster set CusName=?,Address1='" + details.get("add1") + "',Address2='" + details.get("add2") + "',"
                    + "Address3='" + details.get("add3") + "',Address4='" + details.get("add4") + "'"
                    + ",Phone='" + details.get("phone") + "',Email='" + details.get("email") + "'"
                    + ",HomePage='" + details.get("web") + "',Country='" + details.get("country") + "'"
                    + ",Status='" + details.get("status") + "'"
                    + " where  CusCode=? ";
            
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(2, (details.get("cuscode").toString().equals("")?null:details.get("cuscode").toString()));
            stmt.setString(1, (details.get("cusname").toString().equals("")?null:details.get("cusname").toString()));
            stmt.executeUpdate();
        } catch (SQLException e) {
        	if (e instanceof DataTruncation) {
                System.out.println("Parameter causing truncation: " + e.getMessage());
            }
          e.printStackTrace();
        } 
        
    }
	
	
public static void deleteCustomer(String Cuscode) throws Exception {
		
        PreparedStatement stmt;
        try {
        	
            String sql="delete from CustomerMaster where CusCode ='" +  Cuscode + "' ";
            
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } 
    }
}
