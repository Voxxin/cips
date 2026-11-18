package cat.ella.cips.messaging;

import cat.ella.cips.exception.AdmiException;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.ByteArrayInputStream;
import java.io.IOException;

import static cat.ella.cips.exception.AdmiRejectionReason.INTERNAL_ERROR;
import static cat.ella.cips.exception.AdmiRejectionReason.MALFORMED_XML;

public class XMLParser {

    private final DocumentBuilder builder;

    public XMLParser() {
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true);
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            factory.setFeature("http://xml.org/sax/features/external-general-entities", false);
            factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
            factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
            factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
            factory.setXIncludeAware(false);
            factory.setExpandEntityReferences(false);
            builder = factory.newDocumentBuilder();
            builder.setErrorHandler(new DefaultHandler()); // stops the parser printing to stderr
        } catch (ParserConfigurationException e) {
            throw new IllegalStateException("XML parser could not be configured", e);
        }
    }

    public Document parse(byte[] xml) {
        try {
            return builder.parse(new ByteArrayInputStream(xml));
        } catch (SAXException e) {
            throw new AdmiException(MALFORMED_XML, null, e.getMessage(), e);
        } catch (IOException e) {
            throw new AdmiException(INTERNAL_ERROR, null, "Could not read request", e);
        }
    }
}