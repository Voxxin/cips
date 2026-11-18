package cat.ella.cips.domain;

import cat.ella.cips.domain.enums.Role;
import jakarta.persistence.*;

import java.sql.Timestamp;
import java.util.UUID;

@Entity
@Table(name="users")
public class User {
    @Id
    @GeneratedValue(strategy=GenerationType.UUID)
    private UUID id;
    
    @Column(name="user_reference", length=50, unique=true, nullable=false)
    private String userRef;
    
    @Column(name="password_hash", length=60, nullable=false)
    private String passwordHash;

    @Column(name="role", length=11, nullable=false)
    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(name="acc_id", length=15, nullable=false)
    private String accId;

    @Column(name="created_at", nullable=false)
    private Timestamp createdAt;
}