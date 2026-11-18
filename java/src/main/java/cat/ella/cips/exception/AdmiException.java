package cat.ella.cips.exception;

public class AdmiException extends RuntimeException {
    private final AdmiRejectionReason reason;
    private final String location;

    public AdmiException(AdmiRejectionReason reason, String location, String message) {
        this(reason, location, message, null);
    }

    public AdmiException(AdmiRejectionReason reason, String location, String message, Throwable cause) {
        super(message, cause);
        this.reason = reason;
        this.location = location;
    }

    public AdmiRejectionReason reason() { return reason; }
    public String location() { return location; }
}