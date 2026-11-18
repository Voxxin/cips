package cat.ella.cips.messaging;

import cat.ella.cips.exception.AdmiException;
import cat.ella.cips.exception.GlobalExceptionHandler;
import iso.std.iso._20022.tech.xsd.pain_001_001.Document;
import iso.std.iso._20022.tech.xsd.pain_001_001.ObjectFactory;
import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.Unmarshaller;
import jakarta.xml.bind.ValidationEvent;
import jakarta.xml.bind.util.ValidationEventCollector;
import org.springframework.stereotype.Component;

import javax.xml.XMLConstants;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import static cat.ella.cips.exception.AdmiRejectionReason.INTERNAL_ERROR;
import static cat.ella.cips.exception.AdmiRejectionReason.SCHEMA_VALIDATION_FAILURE;

@Component
public class Pain001 {
    private static final String XSD_PATH = "/xsd/pain.001.001.09.xsd";

    private static final JAXBContext context;
    private static final Schema schema;

    static {
        try {
            var xsd = Pain001.class.getResource(XSD_PATH);
            if (xsd == null) {
                throw new IllegalStateException("Missing classpath resource " + XSD_PATH);
            }
            var factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            factory.setProperty(XMLConstants.ACCESS_EXTERNAL_DTD, "");
            factory.setProperty(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
            schema = factory.newSchema(xsd);
            context = JAXBContext.newInstance(ObjectFactory.class);
        } catch (Exception e) {
            throw new IllegalStateException("Could not initialise pain.001 support", e);
        }
    }

    Pain001() {};

    public static Document handle(org.w3c.dom.Document dom) {
        var events = new ValidationEventCollector();
        try {
            Unmarshaller unmarshaller = context.createUnmarshaller();
            unmarshaller.setSchema(schema);
            unmarshaller.setEventHandler(events);

            JAXBElement<Document> root = unmarshaller.unmarshal(dom, Document.class);

            ValidationEvent first = firstProblem(events);
            if (first != null) throw fromEvent(first, null);

            return root.getValue();
        } catch (JAXBException e) {
            ValidationEvent first = firstProblem(events);
            if (first != null) throw fromEvent(first, e);
            throw new AdmiException(INTERNAL_ERROR, null, "Unable to process message", e);
        }
    }

    private static ValidationEvent firstProblem(ValidationEventCollector events) {
        for (ValidationEvent ev : events.getEvents()) {
            if (ev.getSeverity() != ValidationEvent.WARNING) return ev;
        }
        return null;
    }

    private static AdmiException fromEvent(ValidationEvent ev, Throwable cause) {
        String msg = ev.getMessage() != null ? ev.getMessage() : "Schema validation failure";
        return new AdmiException(
                SCHEMA_VALIDATION_FAILURE,
                GlobalExceptionHandler.describeLocation(ev.getLocator()),
                msg, cause);
    }
}