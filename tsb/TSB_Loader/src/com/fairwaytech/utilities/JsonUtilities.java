package com.fairwaytech.utilities;

import com.fairwaytech.models.Configuration;
import com.fairwaytech.models.TestSpecBankRegistration;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.Optional;

/**
 * Created by gregwhite on 6/14/17.
 */
public class JsonUtilities {

    public static Optional<Configuration> Load(File file) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return Optional.of(mapper.readValue(file, Configuration.class));
        } catch (IOException e) {
            e.printStackTrace();
        }
        return Optional.empty();
    }

    public static String toJson(TestSpecBankRegistration registration)  {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.writeValueAsString(registration);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        return null;
    }
}
