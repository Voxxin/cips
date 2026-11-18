package cat.ella.cips.exception;

public enum AdmiRejectionReason {
    MALFORMED_XML("Malformed XML", 400),
    SCHEMA_VALIDATION_FAILURE("Schema validation failure", 422),
    UNSUPPORTED_MESSAGE_TYPE("Unsupported message type", 422),
    BAD_REQUEST("Bad request", 400),
    UNSUPPORTED_ENDPOINT("Unsupported endpoint", 404),
    METHOD_NOT_ALLOWED("Method not allowed", 405),
    UNEXPECTED_MESSAGE_TYPE("Unexpected message type", 422),
    MISSING_MANDATORY_ELEMENT("Missing mandatory element", 422),
    INVALID_ELEMENT_VALUE("Invalid element value", 422),
    DUPLICATE_MESSAGE_ID("Duplicate message ID", 409),
    AUTHENTICATION_FAILURE("Authentication failure", 401),
    AUTHORIZATION_FAILURE("Authorization failure", 403),
    INTERNAL_ERROR("Internal error", 500);

    private final String rejectionReason;
    private final int httpStatus;

    AdmiRejectionReason(String rejectionReason, int httpStatus) {
        this.rejectionReason = rejectionReason;
        this.httpStatus = httpStatus;
    }

    public String reason() { return rejectionReason; }
    public int httpStatus() { return httpStatus; }
}