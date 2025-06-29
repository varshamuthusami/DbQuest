package com.dbquest.dbq;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Welcome {
	
	 @RequestMapping("/DbQuest")
	    public String index() {
	        return "Greetings from DbQuest!";
	    }
	
}
