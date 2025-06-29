package com.dbquest.dbq.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import org.springframework.ui.ModelMap;

import com.dbquest.dbq.utils.ConnectionManager;

public class DBEasyPro {
	
	private static Connection conn = null;
	
	public static ArrayList<ModelMap> getDepartmentNamesFromEasyProVideo() {
	    String sql = "SELECT DISTINCT d.DeptName, SlNo " +
	                 "FROM EasyProVideo ev " +
	                 "JOIN Department d ON ev.DeptCode = d.DeptCode";

	    ArrayList<ModelMap> model = new ArrayList<>();
	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement pStmt = conn.prepareStatement(sql);
	         ResultSet rs = pStmt.executeQuery()) {

	        while (rs.next()) {
	            ModelMap temp = new ModelMap();
	            temp.put("deptName", rs.getString("DeptName"));
	            temp.put("SlNo", rs.getString("SlNo"));
	            model.add(temp);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return model;
	}

	public static ArrayList<ModelMap> getEasyProVideoFilesBySlNo(String slNo) {
	    String sql = "SELECT SlNo, VideoNo, ProcessDesc " +
	                 "FROM EasyProVideoFiles " +
	                 "WHERE SlNo = ?";

	    ArrayList<ModelMap> model = new ArrayList<>();
	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement pStmt = conn.prepareStatement(sql)) {

	        pStmt.setString(1, slNo); // Set the given SlNo

	        ResultSet rs = pStmt.executeQuery();

	        while (rs.next()) {
	            ModelMap temp = new ModelMap();
	            temp.put("slNo", rs.getString("SlNo"));
	            temp.put("videoNo", rs.getString("VideoNo"));
	            temp.put("processDesc", rs.getString("ProcessDesc"));
	            model.add(temp);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return model;
	}

	public static ArrayList<ModelMap> getVideoLinksBySlNoAndVideoNo(String slNo, String videoNo) {
	    String sql = "SELECT SlNo, VideoNo, VideoSeq, VideoDesc, VideoLinks " +
	                 "FROM EasyProVideoFilesLinks " +
	                 "WHERE SlNo = ? AND VideoNo = ?";

	    ArrayList<ModelMap> model = new ArrayList<>();
	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement pStmt = conn.prepareStatement(sql)) {

	        pStmt.setString(1, slNo);
	        pStmt.setString(2, videoNo);

	        ResultSet rs = pStmt.executeQuery();

	        while (rs.next()) {
	            ModelMap temp = new ModelMap();
	            temp.put("slNo", rs.getString("SlNo"));
	            temp.put("videoNo", rs.getString("VideoNo"));
	            temp.put("videoSeq", rs.getString("VideoSeq"));
	            temp.put("videoDesc", rs.getString("VideoDesc"));
	            temp.put("videoLinks", rs.getString("VideoLinks"));
	            model.add(temp);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return model;
	}

}
