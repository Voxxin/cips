package cat.ella.cips.domain.enums;

public enum TransactionLogState {
    SUBMITTED,
    BATCHED,
    VALIDATED,
    SETTLED,
    REJECTED,
    SKIPPED
}