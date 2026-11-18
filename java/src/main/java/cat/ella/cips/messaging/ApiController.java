package cat.ella.cips.messaging;

import cat.ella.cips.exception.AdmiException;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import static cat.ella.cips.exception.AdmiRejectionReason.UNSUPPORTED_MESSAGE_TYPE;

@RestController
public class ApiController {
    ApiController() {}

    @PostMapping(path = "api",
            consumes = {MediaType.APPLICATION_XML_VALUE, MediaType.TEXT_XML_VALUE},
            produces = MediaType.APPLICATION_XML_VALUE)
    public ResponseEntity<Void> postXML(@RequestBody byte[] body) {
        var dom = new XMLParser().parse(body);

        var format = SupportedFormat.find(dom.getDocumentElement().getNamespaceURI());
        if (format == null) {
            throw new AdmiException(UNSUPPORTED_MESSAGE_TYPE, null, "Unsupported XML namespace");
        }

        switch (format) {
            case PAIN001_001_09 -> Pain001.handle(dom);
            default -> throw new AdmiException(UNSUPPORTED_MESSAGE_TYPE, null,
                    "Message type not handled yet");
        }
        return ResponseEntity.accepted().build();
    }
}