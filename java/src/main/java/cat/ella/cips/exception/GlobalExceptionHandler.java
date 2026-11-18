package cat.ella.cips.exception;

import cat.ella.cips.messaging.IsoBuilder;
import iso.std.iso._20022.tech.xsd.admi_002_001.Document;
import iso.std.iso._20022.tech.xsd.admi_002_001.ObjectFactory;
import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.Marshaller;
import jakarta.xml.bind.ValidationEventLocator;
import org.jspecify.annotations.NonNull;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpMediaTypeNotAcceptableException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import org.springframework.web.servlet.resource.NoResourceFoundException;
import org.w3c.dom.Node;

import java.io.StringWriter;
import java.util.logging.Level;
import java.util.logging.Logger;

import static cat.ella.cips.exception.AdmiRejectionReason.*;

@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {
    private static final Logger LOG = Logger.getLogger("CIPS");
    private static final JAXBContext CTX;
    private static final int MAX_DESCRIPTION = 350;
    private static final String FALLBACK =
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Error>Internal error</Error>";

    static {
        try {
            CTX = JAXBContext.newInstance(ObjectFactory.class);
        } catch (JAXBException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static String admiToXml(AdmiRejectionReason reason, String location, String description) {
        try {
            Document doc = IsoBuilder.admiBuilder(reason, location, truncate(description));
            JAXBElement<Document> root = new ObjectFactory().createDocument(doc);
            Marshaller m = CTX.createMarshaller();
            m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
            StringWriter sw = new StringWriter();
            m.marshal(root, sw);
            return sw.toString();
        } catch (JAXBException | RuntimeException e) {
            LOG.log(Level.SEVERE, "Could not build admi.002 response", e);
            return FALLBACK;
        }
    }

    private static String truncate(String s) {
        if (s == null) return "";
        return s.length() <= MAX_DESCRIPTION ? s : s.substring(0, MAX_DESCRIPTION);
    }

    private static ResponseEntity<String> xml(int status, String body) {
        return ResponseEntity.status(status).contentType(MediaType.APPLICATION_XML).body(body);
    }

    @ExceptionHandler(AdmiException.class)
    public ResponseEntity<String> handleAdmi(AdmiException e) {
        var r = e.reason();
        if (r.httpStatus() >= 500) {
            LOG.log(Level.SEVERE, "[" + r + "] " + e.getMessage(), e);
        } else {
            LOG.log(Level.WARNING, "[{0}] {1}", new Object[]{r, e.getMessage()});
        }
        String description = r.httpStatus() >= 500 ? "Internal error" : e.getMessage();
        return xml(r.httpStatus(), admiToXml(r, e.location(), description));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleAnything(Exception e) {
        LOG.log(Level.SEVERE, "Unhandled exception", e);
        return xml(500, admiToXml(INTERNAL_ERROR, null, "Internal error"));
    }


    @Override
    protected ResponseEntity<Object> handleExceptionInternal(@NonNull Exception ex, Object body, @NonNull HttpHeaders headers, @NonNull HttpStatusCode status, @NonNull WebRequest request) {
        AdmiRejectionReason reason;
        String description;

        if (ex instanceof HttpMessageNotReadableException) {
            reason = MALFORMED_XML;
            description = "Request body could not be read";
        } else if (ex instanceof HttpMediaTypeNotSupportedException
                || ex instanceof HttpMediaTypeNotAcceptableException) {
            reason = UNSUPPORTED_MESSAGE_TYPE;
            description = ex.getMessage();
        } else if (ex instanceof HttpRequestMethodNotSupportedException) {
            reason = METHOD_NOT_ALLOWED;
            description = ex.getMessage();
        } else if (ex instanceof NoResourceFoundException || ex instanceof NoHandlerFoundException) {
            reason = UNSUPPORTED_ENDPOINT;
            description = ex.getMessage();
        } else if (status.is5xxServerError()) {
            reason = INTERNAL_ERROR;
            description = "Internal error";
        } else {
            reason = BAD_REQUEST;
            description = "Bad request";
        }

        if (status.is5xxServerError()) {
            LOG.log(Level.SEVERE, "[" + reason + "] " + ex.getMessage(), ex);
        } else {
            LOG.log(Level.WARNING, "[{0}] {1}", new Object[]{reason, ex.getMessage()});
        }

        HttpHeaders out = new HttpHeaders();
        out.putAll(headers);
        out.setContentType(MediaType.APPLICATION_XML);

        return ResponseEntity.status(status)
                .headers(out)
                .body(admiToXml(reason, null, description));
    }

    public static String describeLocation(ValidationEventLocator loc) {
        String UNKNOWN = "Unknown Location";
        if (loc == null) return UNKNOWN;

        StringBuilder sb = new StringBuilder();
        Node node = loc.getNode();
        if (node != null && node.getLocalName() != null) sb.append("<").append(node.getLocalName()).append(">");

        int line = loc.getLineNumber();
        int col = loc.getColumnNumber();
        if (line > 0) {
            if (!sb.isEmpty()) sb.append(" at ");
            sb.append("line ").append(line);
            if (col > 0) sb.append(", column ").append(col);
        }
        return sb.isEmpty() ? UNKNOWN : sb.toString();
    }
}