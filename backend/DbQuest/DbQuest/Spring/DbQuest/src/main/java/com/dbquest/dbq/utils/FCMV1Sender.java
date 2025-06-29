package com.dbquest.dbq.utils;

import com.google.auth.oauth2.GoogleCredentials;
import okhttp3.*;

import java.io.FileInputStream;
import java.util.Collections;

public class FCMV1Sender {

    private static final String FCM_ENDPOINT = "https://fcm.googleapis.com/v1/projects/dbquest-77958/messages:send";

    public static void sendNotification(String title, String body, String token) throws Exception {
        // 1. Load credentials
        GoogleCredentials credentials = GoogleCredentials
                .fromStream(new FileInputStream("path/to/your-service-account.json"))
                .createScoped(Collections.singleton("https://www.googleapis.com/auth/firebase.messaging"));

        credentials.refreshIfExpired();
        String accessToken = credentials.getAccessToken().getTokenValue();

        // 2. Build JSON payload
        String json = "{\n" +
                "  \"message\": {\n" +
                "    \"token\": \"" + token + "\",\n" +
                "    \"notification\": {\n" +
                "      \"title\": \"" + title + "\",\n" +
                "      \"body\": \"" + body + "\"\n" +
                "    }\n" +
                "  }\n" +
                "}";

        // 3. Send HTTP request using OkHttp
        OkHttpClient client = new OkHttpClient();

        Request request = new Request.Builder()
                .url(FCM_ENDPOINT)
                .post(RequestBody.create(json, MediaType.parse("application/json")))
                .addHeader("Authorization", "Bearer " + accessToken)
                .build();

        Response response = client.newCall(request).execute();
        System.out.println("Response code: " + response.code());
        System.out.println("Response body: " + response.body().string());
    }
}
