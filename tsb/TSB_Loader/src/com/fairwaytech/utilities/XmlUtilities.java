package com.fairwaytech.utilities;

import com.fairwaytech.models.TestSpecBankRegistration;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Base64;
import java.util.zip.Deflater;

/**
 * Created by gregwhite on 6/15/17.
 */
public class XmlUtilities {

    public static TestSpecBankRegistration Generate(File file, String tenantId) {
        TestSpecBankRegistration result = new TestSpecBankRegistration();
        result.setTenantId(tenantId);
        result.setCategory("");
        result.setPurpose("REGISTRATION");

        Document document = retrieveXmlFromFile(file);
        if(document == null) {
            System.out.println();
            System.out.println("There was a problem loading XML input file: " + file.getName());
            return null;
        }
        try {
            XPath xPath = XPathFactory.newInstance().newXPath();
            result.setSubjectAbbreviation(xPath.evaluate("./testspecification/property[@name='subject']/@value", document));
            switch(result.getSubjectAbbreviation()) {
                case "ELA":
                    result.setSubjectName("English Language Arts");
                    break;
                case "MATH":
                    result.setSubjectName("Mathematics");
                    break;
                case "Student Help":
                    result.setSubjectName("Student Help");
                    break;
                default:
                    System.out.println();
                    System.out.println("Unrecognized subject: " + result.getSubjectAbbreviation());
                    return null;
            }
            result.setName(xPath.evaluate("./testspecification/identifier/@uniqueid", document));
            result.setLabel(xPath.evaluate("./testspecification/identifier/@label", document));
            String testType = xPath.evaluate("./testspecification/property[@name='type']/@value", document);
            switch(testType) {
                case "interim":
                    result.setType("I");
                    break;
                case "summative":
                    result.setType("S");
                    break;
                default:
                    System.out.println();
                    System.out.println("Unrecognized type: " + testType);
                    return null;
            }
            result.setVersion(xPath.evaluate("./testspecification/identifier/@version", document));
            XPathExpression expression = xPath.compile("./testspecification/property[@name='grade']/@value");
            NodeList nodeList = (NodeList) expression.evaluate(document, XPathConstants.NODESET);
            String[] grades = new String[nodeList.getLength()];
            for(int i = 0; i < nodeList.getLength(); i++) {
                grades[i] = nodeList.item(i).getNodeValue();
            }
            result.setGrade(grades);

            NodeList nameList = (NodeList) xPath.compile("./testspecification/identifier/@name").evaluate(document, XPathConstants.NODESET);
            nameList.item(0).setNodeValue(result.getName());

            // Compress xml
            byte[] output = new byte[4096];
            replaceTestNameWithUniqueId(file);
            Deflater compressor = new Deflater();
            compressor.setInput(Files.readAllBytes(file.toPath()));
            compressor.finish();
            compressor.deflate(output);
            compressor.end();

            result.setSpecificationXml(Base64.getEncoder().encodeToString(output));

        } catch(Exception ex) {
            ex.printStackTrace();
            return null;
        }

        return result;
    }

    private static void replaceTestNameWithUniqueId(final File file) {
    }

    private static Document retrieveXmlFromFile(File file) {
        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder dBuilder;
        try {
            dBuilder = dbFactory.newDocumentBuilder();
            Document doc = dBuilder.parse(file);
            return doc;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
