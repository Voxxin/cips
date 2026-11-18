package cat.ella.cips.messaging;

public enum SupportedFormat {
    PAIN001_001_09("pain", "001", "001.09"), // Transaction request from member
    PAIN002_001_10("pain", "002", "001.10"), // Internal transaction update
    ADMI002_001_01("admi","002", "001.01"); // Message rejection

    private final String domain;
    private final String kind;
    private final String version;

    SupportedFormat(String domain, String kind, String version) {
        this.domain = domain;
        this.kind = kind;
        this.version = version;
    }

    public String formattedTitle() {
        return "urn:iso:std:iso:20022:tech:xsd:" + this.domain+"."+this.kind+"."+ this.version;
    }

    public static SupportedFormat find(String value) {
        SupportedFormat returnVal = null;
        for (SupportedFormat format : values()) {
            if (format.formattedTitle().equals(value)) {
                returnVal = format;
                break;
            }
        }
        return returnVal;
    }
}