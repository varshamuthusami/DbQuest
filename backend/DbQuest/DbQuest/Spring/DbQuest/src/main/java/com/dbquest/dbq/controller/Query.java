package com.dbquest.dbq.controller;

import java.io.IOException;
import java.util.ArrayList;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.dbquest.dbq.model.SpnCustom;
import com.dbquest.dbq.service.DBQuery;
import com.dbquest.dbq.utils.PropertiesManager;

@RestController
public class Query {
	private static final PropertiesConfiguration properties = PropertiesManager.getInstance().getProperties();
	private static final Logger LOG = LoggerFactory.getLogger(Query.class);
	
	 @RequestMapping("/getQuery")
	    @ResponseBody    
	    public String getString(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "sqlQuery") String sqlQuery,
	        @RequestParam(value = "param1", defaultValue = "") String param1,
	        @RequestParam(value = "param2", defaultValue = "") String param2,
	        @RequestParam(value = "param3", defaultValue = "") String param3) {
		 	LOG.error("getQuery");
		 	String value = "";
		 	if(properties.getString("api.key").equals(currentToken)) {
		 		value = DBQuery.getQuery(sqlQuery, param1, param2, param3);
		 	}			 	
	        return value;
	    } 
	 
	 @RequestMapping("/getInt")
	    @ResponseBody    
	    public Integer getInt(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "sqlQuery") String sqlQuery,
	        @RequestParam(value = "param1", defaultValue = "") String param1,
	        @RequestParam(value = "param2", defaultValue = "") String param2,
	        @RequestParam(value = "param3", defaultValue = "") String param3) {
		 	LOG.error("getInt");
		 	Integer value = DBQuery.getInt(sqlQuery, param1, param2, param3);
	        return value;
	    } 
	 
	 @RequestMapping("/getSpinnerData")
	    @ResponseBody    
	    public ArrayList<SpnCustom> getSpinnerData(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "sqlQuery") String sqlQuery) {
		 	LOG.error("getSpinnerData");
		 	ArrayList<SpnCustom> spn = new ArrayList<SpnCustom>();
		 	if(properties.getString("api.key").equals(currentToken)) {
		 		spn = DBQuery.getSpinnerData(sqlQuery);
		 	}	
	        return spn;
	    } 
	 
	 @RequestMapping("/getSpinSingleData")
	    @ResponseBody    
	    public ArrayList<String> getSpinSingleData(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "sqlQuery") String sqlQuery) {
		 	LOG.error("getSpinSingleData");
		 	ArrayList<String> spn = new ArrayList<String>();
		 	if(properties.getString("api.key").equals(currentToken)) {
		 		spn = DBQuery.getSpinSingleData(sqlQuery);
		 	}	
	        return spn;
	    } 
	 
	 @RequestMapping(value = "/getBlob", produces = MediaType.IMAGE_JPEG_VALUE)
	    @ResponseBody    
	    public byte[] getBlob(
	    	@RequestHeader(value = "currentToken") String currentToken,
	        @RequestHeader(value = "oldToken", defaultValue = "") String oldToken,
	        @RequestParam(value = "sqlQuery") String sqlQuery,
	        @RequestParam(value = "param1", defaultValue = "") String param1,
	        @RequestParam(value = "param2", defaultValue = "") String param2,
	        @RequestParam(value = "param3", defaultValue = "") String param3) {
		 	LOG.error("getBlob");
		 	byte[] value = DBQuery.getBlob(sqlQuery, param1, param2, param3);
	        return value;
	    } 
	 
	 @RequestMapping(value = "/getImage", method = RequestMethod.GET,
	            produces = MediaType.IMAGE_JPEG_VALUE)
	    public ResponseEntity<byte[]> getImage(String sql) throws IOException {
	        
	        byte[] bytes = DBQuery.getBlob(sql, "", "", "");

	        return ResponseEntity
	                .ok()
	                .contentType(MediaType.IMAGE_JPEG)
	                .body(bytes);
	    }
	
}
