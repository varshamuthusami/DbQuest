package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBProjectMaster {
	
	private static Connection conn = null;
	
	public static ArrayList<ModelMap> getProjectMaster() {
        String sql = "select ProjectID,ProjectDesc,\r\n" + 
        		"  Customer,(select CusName from CustomerMaster where CusCode=Customer),\r\n" + 
        		"  Technology,(select ParamDesc from Parameter where ParamType='TEC' and ParamID=Technology),\r\n" + 
        		"  Manager,(select EmpName from EmployeeMaster where EmpID=Manager),\r\n" + 
        		"  CONVERT(varchar,CreationDate, 103),CONVERT(varchar,ExpDueDate,103),CONVERT(varchar,CompletionDate,103),\r\n" + 
        		"  CurrentStatus,(select ParamDesc from Parameter where ParamType='STS' and ParamID=CurrentStatus) \r\n" + 
        		"  from ProjectMaster";

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
            	temp.put("cuscode", rs.getString(3));
            	temp.put("cusname", rs.getString(4));
            	temp.put("tech", rs.getString(5));
            	temp.put("techdesc", rs.getString(6));
            	temp.put("manager", rs.getString(7));
            	temp.put("manname", rs.getString(8));
            	temp.put("credate", rs.getString(9));
            	temp.put("expdate", rs.getString(10));
            	temp.put("comdate", rs.getString(11));
            	temp.put("status", rs.getString(12));
            	temp.put("statusdesc", rs.getString(13));
            	model.add(temp);
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
      
        return model;
    }	

	public static ArrayList<ModelMap> getProjMasterSpinnersData() {
	    
		 String sql = "select CusCode,CusName from CustomerMaster";
		 
		 String sql1 = "select ParamID,ParamDesc from Parameter where ParamType='TEC'";
		 
		 String sql2 = "select EmpID,EmpName from EmployeeMaster";
		 
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
          	temp.put("sCode", rs1.getString(1).trim());
          	temp.put("sDesc", rs1.getString(2));
          	model1.add(temp);
	        }
	        conn.close();   
	        
	        conn = ConnectionManager.getConnection();
	        pStmt2 = conn.prepareStatement(sql2);
	        rs2 = pStmt2.executeQuery();

	        while (rs2.next()) {
	        	ModelMap temp = new ModelMap();
          	temp.put("sCode", rs2.getString(1).trim());
          	temp.put("sDesc", rs2.getString(2));
          	model2.add(temp);
	        }
	        conn.close();   
	        
	        
	    	ModelMap temp = new ModelMap();
	    	temp.put("Customer", model);
	    	temp.put("Technology", model1);
	    	temp.put("Manager", model2);
	    	
	    	modela.add(temp);
	    	
	    	conn.close();
	    } catch (Exception e) {
	        e.printStackTrace();
	    } 
	  
	    return modela;
	}

	public static void addProjectMaster(ModelMap details) throws Exception {	
        PreparedStatement stmt;
        try {
        	
            String sql = "INSERT INTO ProjectMaster (ProjectId,ProjectDesc,Customer,Technology,Manager,ExpDueDate,CompletionDate,CreationDate,CurrentStatus) "
            		+ " VALUES ((select isnull(max(ProjectId),0)+1  from ProjectMaster),?,'" + details.get("customer") + "','" + details.get("technology") +"', "
            		+ " '" + details.get("manager") + "',?,?,getdate(),'O') ";
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, (details.get("pdesc").toString().equals("")?null:details.get("pdesc").toString()));
            stmt.setString(2, (details.get("expdate").toString().equals("")?null:details.get("expdate").toString()));
            stmt.setString(3, (details.get("comdate").toString().equals("")?null:details.get("comdate").toString()));
            
            stmt.executeUpdate();
            
        } catch (SQLException e) {
        	
          e.printStackTrace();
          
        } 
        
    }

	public static void deleteProject(String pid) throws Exception {
		
        PreparedStatement stmt;
        try {
        	
            String sql="delete from ProjectMaster where ProjectID ='" +  pid + "' ";
            
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

	public static void updateProjectMaster(ModelMap details) throws Exception {
		
        PreparedStatement stmt;
        try {    
        	
            String sql="update ProjectMaster set ProjectDesc=?,"
            	    	+ "Customer='" + details.get("customer") + "',Technology='" + details.get("technology") + "'"
            	    			+ ",Manager='" + details.get("manager") + "',ExpDueDate=?"
            	    					+ ",CompletionDate=?\r\n" + 
            	    	"where  ProjectID='" + details.get("pid") + "'  ";
            
            conn = ConnectionManager.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, (details.get("pdesc").toString().equals("")?null:details.get("pdesc").toString()));
            stmt.setString(2, (details.get("expdate").toString().equals("")?null:details.get("expdate").toString()));
            stmt.setString(3, (details.get("comdate").toString().equals("")?null:details.get("comdate").toString()));
            stmt.executeUpdate();
        } catch (SQLException e) {
          e.printStackTrace();
        } 
        
    }
}
