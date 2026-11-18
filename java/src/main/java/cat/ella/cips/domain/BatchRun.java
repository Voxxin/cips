package cat.ella.cips.domain;

import jakarta.persistence.*;

import java.sql.Timestamp;
import java.util.UUID;

@Entity
@Table(name="batch_runs")
public class BatchRun {
    @Id
    @GeneratedValue(strategy= GenerationType.UUID)
    private UUID id;

    @Column(name="started_at", nullable=false)
    private Timestamp startedAt;

    @Column(name="completed_at")
    private Timestamp completedAt;

    @Column(name="step_validate_rc")
    private Integer rcValidate;

    @Column(name="step_post_rc")
    private Integer rcPost;

    @Column(name="step_report_rc")
    private Integer rcReport;

    @Column(name="final_rc")
    private Integer rcFinal;

    @Column(name="log_file_path")
    private String logFilePath;
}