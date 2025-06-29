package com.dbquest.dbq.utils;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtil {

    public static void sendEmail(String toEmail, String subject, String messageBody) throws Exception {
        final String fromEmail = "dbquestbusinesssolutions2025@gmail.com"; // sender email
        final String password = "hjtcuuqhrapjqnri";     // App-specific password from Google

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com"); // SMTP Host
        props.put("mail.smtp.port", "587");            // TLS Port
        props.put("mail.smtp.auth", "true");           // Enable authentication
        props.put("mail.smtp.starttls.enable", "true");// Enable STARTTLS

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromEmail));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setText(messageBody);

        Transport.send(message);
    }
}
