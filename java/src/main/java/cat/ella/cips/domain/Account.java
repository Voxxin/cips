package cat.ella.cips.domain;

import cat.ella.cips.domain.enums.AccountStatus;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Formula;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name="accounts")
public class Account {
    @Id
    @GeneratedValue(strategy=GenerationType.UUID)
    private UUID id;

    /*
    *   transitNumber, institutionNumber, and accountNumber are used to make accId.
    *   accId is the account ID used in COBOL programs.
    */

    @Column(name="transit_number", length=5, nullable=false)
    private String transitNumber;

    @Column(name="institution_number", length=3, nullable=false)
    private String institutionNumber;

    @Column(name="account_number", length=7, nullable=false)
    private String accountNumber;

    /*
    *   END OF accId VALUES
    */

    @Formula("concat(transit_number, institution_number, account_number)")
    @Column(name="acc_id", insertable=false, updatable=false, unique=true)
    private String accId;

    @Column(name="owner_name", length=30, nullable=false)
    private String ownerName;

    @Column(name="balance", precision=15, scale=2, nullable=false)
    private BigDecimal balance;

    @Column(name="daily_spent", precision=15, scale=2, nullable=false)
    private BigDecimal dailySpent;

    @Column(name="daily_limit", precision=15, scale=2, nullable=false)
    private BigDecimal dailyLimit;

    @Column(name="status", columnDefinition =  "char(1)", nullable=false)
    private Character status;

    @Column(name="currency", length=3, nullable=false)
    private String currency;

    @CreationTimestamp
    private OffsetDateTime createdAt;

}