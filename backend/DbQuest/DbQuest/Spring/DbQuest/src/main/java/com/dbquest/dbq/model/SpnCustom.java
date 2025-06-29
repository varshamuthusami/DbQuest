package com.dbquest.dbq.model;

public class SpnCustom {

    private String sCode;
    private String sDesc;

    public SpnCustom(String sCode, String sDesc){
        super();
        this.sCode = sCode;
        this.sDesc = sDesc;
    }
    public String getsCode() {
        return sCode;
    }
    public String getsDesc() {
        return sDesc;
    }
}
