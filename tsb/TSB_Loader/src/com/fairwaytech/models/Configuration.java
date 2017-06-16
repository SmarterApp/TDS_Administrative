package com.fairwaytech.models;

import java.net.URL;

/**
 * Created by gregwhite on 6/14/17.
 */
public class Configuration {
    private String openAmUri;
    private String openAmClientSecret;
    private String programMgmtUri;
    private String programMgmtTenant;
    private String programMgmtTenantLevel;
    private String progManUserId;
    private String progManPassword;
    private String testSpecBankUri;
    private String testSpecBankUserId;
    private String testSpecBankPassword;

    public String getOpenAmUri() {
        return openAmUri;
    }

    public String getOpenAmClientSecret() {
        return openAmClientSecret;
    }

    public String getProgramMgmtUri() {
        return programMgmtUri;
    }

    public String getProgramMgmtTenant() {
        return programMgmtTenant;
    }

    public String getProgramMgmtTenantLevel() {
        return programMgmtTenantLevel;
    }

    public String getProgManUserId() {
        return progManUserId;
    }

    public String getProgManPassword() {
        return progManPassword;
    }

    public String getTestSpecBankUri() {
        return testSpecBankUri;
    }

    public String getTestSpecBankUserId() {
        return testSpecBankUserId;
    }

    public String getTestSpecBankPassword() {
        return testSpecBankPassword;
    }

    // Lots of tasty validations
    public boolean isValid() {
        return openAmUri != null && !openAmUri.isEmpty() && isUriValid(openAmUri)
        && openAmClientSecret != null && !openAmClientSecret.isEmpty()
        && programMgmtUri != null && !programMgmtUri.isEmpty() && isUriValid(programMgmtUri)
        && programMgmtTenant != null && !programMgmtTenant.isEmpty()
        && programMgmtTenantLevel != null && !programMgmtTenantLevel.isEmpty()
        && progManUserId != null && !progManUserId.isEmpty()
        && progManPassword != null && !progManPassword.isEmpty()
        && testSpecBankUri != null && !testSpecBankUri.isEmpty() && isUriValid(testSpecBankUri)
        && testSpecBankUserId != null && !testSpecBankUserId.isEmpty()
        && testSpecBankPassword != null && !testSpecBankPassword.isEmpty();
    }

    private static boolean isUriValid(String uri) {
        final URL url;
        try {
            url = new URL(uri);
        } catch (Exception ex) {
            System.out.println("Provided uri value: " + uri + " is not valid");
            return false;
        }
        return "utilities".equals(url.getProtocol())
                || "https".equals(url.getProtocol());
    }
}
