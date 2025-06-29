/*package com.dbquest.dbq.utils;

import java.io.File;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class FileStorageUtil {

    private static String baseUploadDir;

    @Value("${file.upload-dir}")
    public void setBaseUploadDir(String dir) {
        baseUploadDir = dir;
    }

    public static String getUploadPath(String projectId, String taskId) {
        String path = baseUploadDir + File.separator + "project_" + projectId + File.separator + "task_" + taskId;
        File dir = new File(path);
        if (!dir.exists()) dir.mkdirs();
        System.out.println("Upload directory resolved to: " + path);
        return path;
    }
    
        public static String buildDownloadUrl(String fileName, String projectId, String taskId) {
            if (fileName == null || fileName.trim().isEmpty()) return null;

            return AppConfig.getBaseUrl()
                    + "/ProjectTaskDownload/file?FileName=" + fileName
                    + "&PID=" + projectId
                    + "&TASKID=" + taskId;
        }
}*/

