package com.dbquest.dbq.model;

public class SpnTask {
    private String sTid;
    private String sTdesc;
    private String sType;
    private String sPc;

    public SpnTask(String sTid, String sTdesc, String sType, String sPc) {
        super();
        this.sTid = sTid;
        this.sTdesc = sTdesc;
        this.sType = sType;
        this.sPc = sPc;
    }

    public String getsTid() {
        return sTid;
    }

    public String getsTdesc() {
        return sTdesc;
    }

    public String getsType() {
        return sType;
    }

    public String getsPc() {
        return sPc;
    }
}
