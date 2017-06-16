package com.fairwaytech;

import com.fairwaytech.models.TestSpecBankRegistration;
import com.fairwaytech.utilities.ParameterUtilities;
import com.fairwaytech.utilities.HttpUtilities;
import com.fairwaytech.utilities.JsonUtilities;
import com.fairwaytech.models.Configuration;
import com.fairwaytech.models.Project;
import com.fairwaytech.utilities.XmlUtilities;
import org.apache.commons.cli.CommandLine;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class Main {

    private static String HELP_TEXT =
            "The TSB loader takes three arguments. The first \"-c\" \n" +
            "indicates the path to the JSON configuration file that \n" +
            "contains the credential information necessary to \n" +
            "communicate with OpenAM, ProgMan, and the TestSpecBank. \n" +
            "The second, \"-x\" causes the script to execute against \n" +
            "these targets using live data. Running this script without \n" +
            "the \"-x\" option enabled will result in a dry run; No data \n" +
            "will be sent persisted in external systems. The third argument \n" +
            "\"-p\" indicates the path to the target test administration \n" +
            "package or a directory containing many test administration \n" +
            "packages that are to be loaded into ART.";

    public static void main(String[] args) {
        Optional<CommandLine> arguments = ParameterUtilities.parseCommandLineArguments(args);
        if(!ParameterUtilities.validateCommandLineArguments(arguments)) {
            errorOut();
        }
        Optional<Configuration> configuration = JsonUtilities.Load(new File(arguments.get().getOptionValue("c")));
        if(!configuration.isPresent() && configuration.get().isValid()) {
            errorOut();
        }
        String progmanOpenAMToken = HttpUtilities.authenticateWithProject(configuration.get(), Project.PROGMAN);
        if(progmanOpenAMToken == null || progmanOpenAMToken.isEmpty()) {
            errorOut();
        }
        String tenantId = HttpUtilities.retrieveTenantIdFromProgMan(configuration.get(), progmanOpenAMToken);
        if(tenantId == null || tenantId.isEmpty()) {
            errorOut();
        }
        String testSpecBankOpenAMToken = HttpUtilities.authenticateWithProject(configuration.get(), Project.TESTSPECBANK);
        if(testSpecBankOpenAMToken == null || testSpecBankOpenAMToken.isEmpty()) {
            errorOut();
        }
        List<TestSpecBankRegistration> registration =
                Arrays.stream(ParameterUtilities.retrieveFiles(arguments.get().getOptionValue("p")))
                .map(x -> XmlUtilities.Generate(x, tenantId)).collect(Collectors.toList());
        if(registration == null || registration.isEmpty()) {
            errorOut();
        }
        registration.stream().forEach(x -> {
            x.setSpecificationXml("");
            System.out.println(JsonUtilities.toJson(x));
        }
        );
        if(arguments.get().hasOption("x") && registration.stream()
                .allMatch(x -> HttpUtilities.pushRegistrationToTestSpecBank(configuration.get(), x, testSpecBankOpenAMToken))) {
            System.out.println("Registration completed successfully");
            try {
                System.in.read();
            } catch (IOException e) {
                e.printStackTrace();
            }
            System.exit(0);
        }
        errorOut();
    }

    private static void errorOut() {
        System.out.println(HELP_TEXT);
        try {
            System.in.read();
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.exit(1);
    }


}
