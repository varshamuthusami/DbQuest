/*package com.dbquest.dbq.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;

public class FCMService {

    public static String sendNotification(String fcmToken, String title, String body) {
        try {
            // Building the notification message
            Message message = Message.builder()
                .setToken(fcmToken)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
                .build();

            // Sending the message
            String response = FirebaseMessaging.getInstance().send(message);
            System.out.println("✅ FCM sent: " + response);
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "FAILURE: " + e.getMessage();
        }
    }
}*/
