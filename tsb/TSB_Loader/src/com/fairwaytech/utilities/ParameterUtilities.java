package com.fairwaytech.utilities;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

import java.io.File;
import java.util.Arrays;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by gregwhite on 6/15/17.
 */
public class ParameterUtilities {

    private static final String JSON = "json";
    private static final String XML = "xml";

    public static Optional<CommandLine> parseCommandLineArguments(String[] args) {
        // There are only three valid arguments to this application. If there are no
        // arguments here, or if there are more than five present (counting path arguments)
        // this method indicates an error condition.
        if(args.length == 0 || args.length > 5) {
            return Optional.empty();
        }
        // This is where the valid arguments to this application are defined
        Options options = new Options();
        options.addRequiredOption("c", "configPath", true, "Path to configuration in JSON format");
        options.addRequiredOption("p", "path", true, "Path to XML Administration package or directory containing XML Administration packages");
        options.addOption("x", "execute", false, "Execute the command");
        CommandLineParser parser = new DefaultParser();
        try {
            return Optional.of(parser.parse( options, args, true));
        } catch (ParseException e) {
            System.out.println(e.getMessage());
            System.out.println();
            e.printStackTrace();
        }
        return Optional.empty();
    }

    public static boolean validateCommandLineArguments(Optional<CommandLine> arguments) {
        boolean validPath;

        // Check that the path argument exists
        if(!arguments.isPresent()
                || !arguments.get().hasOption("p")
                || !arguments.get().hasOption("c")) {
            System.out.println("Unable to properly parse path argument");
            return false;
        }
        String path = arguments.get().getOptionValue("p");
        String configurationPath = arguments.get().getOptionValue("c");
        File pathFile = new File(path);
        File configFile = new File(configurationPath);

        // We need to recognize this path as the path to a valid file or directory that we have read access to
        if(!pathFile.exists()
                || (!pathFile.isFile() && !pathFile.isDirectory())
                || !pathFile.canRead()) {
            System.out.println("Path file at " + pathFile.getAbsolutePath() +
                    " is not of a recognized type or inaccessible due to its protection level");
            return false;
        }
        // We are going to hit all of the files in the directory if a directory is provided
        validPath = pathFile.isDirectory() ?
                Arrays.stream(pathFile.listFiles()).allMatch(x -> validateFile(x, XML))
                : validateFile(pathFile, XML);

        // Directories are not valid paths for config files
        if(!configFile.exists() || !configFile.isFile() || !configFile.canRead()) {
            System.out.println("Configuration file at " + configFile.getAbsolutePath() +
                    " is not of a recognized type or inaccessible due to its protection level");
            return false;
        }

        // The file must match validation
        return validateFile(configFile, JSON) && validPath;
    }

    private static boolean validateFile(File file, String extension) {
        final String regex = "^.+\\." + extension + "$";
        Pattern pattern = Pattern.compile(regex);
        final Matcher matcher = pattern.matcher(file.getName());
        // The file name should appropriately match the required extension
        if(!matcher.matches()) {
            System.out.println("File argument " + file.getName() + " does not have the required extension " + extension);
            return false;
        }
        return true;
    }

    public static File[] retrieveFiles(String target) {
        File file = new File(target);
        if(file.isFile()) {
            return new File[] {file};
        }
        return file.listFiles();
    }
}
