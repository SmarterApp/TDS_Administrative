package com.fairwaytech.utilities;

import com.fairwaytech.models.Configuration;
import com.fairwaytech.models.Project;
import com.fairwaytech.models.TestSpecBankRegistration;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by gregwhite on 6/14/17.
 */
public class HttpUtilities {

    public static final String CHARSET = StandardCharsets.UTF_8.name();

    public static String authenticateWithProject(Configuration configuration, Project project) {
        URLConnection connection;
        String openAMUrl = configuration.getOpenAmUri() + "/auth/oauth2/access_token?realm=/sbac";
        try {
            connection = new URL(openAMUrl).openConnection();
        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println();
            System.out.println("An invalid URL was generated when attempting to retrieve access token from OpenAM: " + openAMUrl);
            return null;
        }
        connection.setDoOutput(true); // Triggers POST.
        connection.setRequestProperty("Accept-Charset", CHARSET);
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + CHARSET);

        String query;
        Map<String, Object> jsonMap;
        try {
            query = project == Project.PROGMAN ?
                    String.format("grant_type=%s&client_id=%s&client_secret=%s&username=%s&password=%s",
                    URLEncoder.encode("password", CHARSET),
                    URLEncoder.encode("pm", CHARSET),
                    URLEncoder.encode(configuration.getOpenAmClientSecret(), CHARSET),
                    URLEncoder.encode(configuration.getProgManUserId(), CHARSET),
                    URLEncoder.encode(configuration.getProgManPassword(), CHARSET))
            :       String.format("grant_type=%s&client_id=%s&client_secret=%s&username=%s&password=%s",
                    URLEncoder.encode("password", CHARSET),
                    URLEncoder.encode("pm", CHARSET),
                    URLEncoder.encode(configuration.getOpenAmClientSecret(), CHARSET),
                    URLEncoder.encode(configuration.getTestSpecBankUserId(), CHARSET),
                    URLEncoder.encode(configuration.getTestSpecBankPassword(), CHARSET));

            OutputStream output = connection.getOutputStream();
            output.write(query.getBytes(StandardCharsets.UTF_8.name()));
            InputStream response = connection.getInputStream();
            ObjectMapper mapper = new ObjectMapper();
            jsonMap = mapper.readValue(response, Map.class);
        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println();
            System.out.println("An invalid encoding: " + CHARSET + " or I/O exception occurred when communicating with OpenAM");
            return null;
        }

        if(!jsonMap.containsKey("access_token")) {
            System.out.println();
            System.out.println("Unable to retrieve authentication token from OpenAM with credentials provided");
            return null;
        }

        return (String) jsonMap.get("access_token");
    }

    public static String retrieveTenantIdFromProgMan(Configuration configuration, String openAMToken) {
        URLConnection connection;
        String progManUrl = configuration.getProgramMgmtUri() + "/rest/tenant";
        String query;
        try {
            query = String.format("name=%s&type=%s",
                    URLEncoder.encode(configuration.getProgramMgmtTenant(), CHARSET),
                    URLEncoder.encode(configuration.getProgramMgmtTenantLevel(), CHARSET));
            connection = new URL(progManUrl + "?" + query).openConnection();
        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println();
            System.out.println("An invalid URL was generated when attempting to " +
                    "retrieve tenant information from ProgMan: " + progManUrl);
            return null;
        }
        connection.setDoOutput(true);
        connection.setRequestProperty("Accept-Charset", CHARSET);
        connection.setRequestProperty("Authorization", "Bearer " + openAMToken);
        Map<String, Object> jsonMap;
        try {
            InputStream response = connection.getInputStream();
            ObjectMapper mapper = new ObjectMapper();
            jsonMap = mapper.readValue(response, Map.class);
        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println();
            System.out.println("An invalid encoding: " + CHARSET + " or I/O exception occurred when communicating with OpenAM");
            return null;
        }

        if(!jsonMap.containsKey("searchResults")) {
            System.out.println();
            System.out.println("Unable to retrieve authentication token from OpenAM with credentials provided");
            return null;
        }

        // Java has terrible type resolution for generics. I should be able to stream over the "results" here and
        // select the information I need returning an Optional type to the caller. Java is clunky, so here's your loop...
        List<Map<String,Object>> results = ((List<Map<String,Object>>) jsonMap.get("searchResults"));
        for(Map<String,Object> result : results) {
            if(result.get("name").toString().equals(configuration.getProgramMgmtTenant())
                    && result.get("type").toString().equals(configuration.getProgramMgmtTenantLevel())) {
                return result.get("id").toString();
            }
        }
        // Obviously this is an error condition. If the caller doesn't have the correct tenancy information, the call
        // will not be successful.
        return null;
    }

    public static boolean pushRegistrationToTestSpecBank(Configuration configuration,
                                                         TestSpecBankRegistration registration, String testSpecBankToken) {
        URLConnection connection;
        String testSpecBankUrl = configuration.getTestSpecBankUri() + "/rest/testSpecification";
        try {
            connection = new URL(testSpecBankUrl).openConnection();
        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println();
            System.out.println("An invalid URL was generated when attempting to push to TestSpecBank: " + testSpecBankUrl);
            return false;
        }
        connection.setDoOutput(true); // Triggers POST.
        connection.setRequestProperty("Accept-Charset", CHARSET);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Authorization", "Bearer " + testSpecBankToken);

        String query;
        try {
            query = JsonUtilities.toJson(registration);

            OutputStream output = connection.getOutputStream();
            output.write(query.getBytes(StandardCharsets.UTF_8.name()));
            InputStream response = connection.getInputStream();
            return true;
        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println();
            System.out.println("An invalid encoding: " + CHARSET + " or I/O exception occurred when communicating with TestSpecBank");
            return false;
        }
    }

}
