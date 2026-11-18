package cat.ella.cips.domain;

import cat.ella.cips.domain.enums.TransactionState;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.UUID;

@Entity
@Table(name="transactions")
public class Transaction {
    @Id
    @GeneratedValue(strategy= GenerationType.UUID)
    private UUID id;

    @Column(name="end_to_end_id", nullable=false)
    private String endToEndId;

    @Column(name="creditor_account_id", length=15, nullable=false)
    private String creditorId;

    @Column(name="debtor_account_id", length=15, nullable=false)
    private String debtorId;

    @Column(name="amount", nullable=false)
    private BigDecimal amount;

    @Column(name="currency", length=3, nullable=false)
    private String currency;

    @Column(name="timestamp_str", nullable=false)
    private String timestamp;

    @Column(name="status", nullable=false)
    @Enumerated(EnumType.STRING)
    private TransactionState status;

    @Column(name="batch_run_id", nullable=false)
    private UUID batchRunId;

    @Column(name="created_at", nullable=false)
    private Timestamp createdAt;

    @Column(name="updated_at", nullable=false)
    private Timestamp updatedAt;
}