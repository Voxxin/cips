package cat.ella.cips.messaging;

import cat.ella.cips.exception.AdmiRejectionReason;
import iso.std.iso._20022.tech.xsd.admi_002_001.Admi00200101;
import iso.std.iso._20022.tech.xsd.admi_002_001.MessageReference;
import iso.std.iso._20022.tech.xsd.admi_002_001.RejectionReason2;

import javax.xml.datatype.DatatypeFactory;
import java.time.Instant;
import java.util.UUID;

public class IsoBuilder {
    private final static DatatypeFactory date = DatatypeFactory.newDefaultInstance();

    protected static String generateId() {
        return "CIPS-" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
    }

    public static iso.std.iso._20022.tech.xsd.admi_002_001.Document admiBuilder(AdmiRejectionReason rjctRsn, String errorLocation, String reasonDescription) {
        iso.std.iso._20022.tech.xsd.admi_002_001.ObjectFactory factory = new iso.std.iso._20022.tech.xsd.admi_002_001.ObjectFactory();
        MessageReference msgRef = factory.createMessageReference();
        RejectionReason2 rjt = factory.createRejectionReason2();
        Admi00200101 admi = factory.createAdmi00200101();
        iso.std.iso._20022.tech.xsd.admi_002_001.Document doc = factory.createDocument();

        msgRef.setRef(generateId());

        rjt.setRjctgPtyRsn(rjctRsn.reason());
        rjt.setRjctnDtTm(date.newXMLGregorianCalendar(Instant.now().toString()));
        if (errorLocation != null && !errorLocation.isEmpty()) rjt.setErrLctn(errorLocation);
        rjt.setRsnDesc(reasonDescription);

        admi.setRltdRef(msgRef);
        admi.setRsn(rjt);

        doc.setAdmi00200101(admi);

        return doc;
    }
}