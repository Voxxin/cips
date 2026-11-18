package cat.ella.cips.domain;

import cat.ella.cips.domain.enums.TransactionLogState;
import jakarta.persistence.*;

import java.sql.Timestamp;
import java.util.UUID;

@Entity
@Table(name="audit_logs")
public class AuditLog {
    @Id
    @GeneratedValue(strategy= GenerationType.UUID)
    private UUID id;

    @Column(name="transaction_id")
    private UUID refTransactionId;

    @Column(name="event_type", length=20, nullable=false)
    @Enumerated(EnumType.STRING)
    private TransactionLogState transactionState;

    @Column(name="message")
    private String reason;

    @Column(name="timestamp", nullable=false)
    private Timestamp timestamp;
}