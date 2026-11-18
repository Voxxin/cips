CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Accounts Table (Banking accounts, what's used in the COBOL programs)
--  NOTE: daily_spent < daily_limit check is done within the COBOL layer.
CREATE TABLE accounts(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- Makes 'ACC-ID' which is used in COBOL programs (reference: acc_id)
    transit_number VARCHAR(5) CHECK(length(transit_number)=5) NOT NULL,
    institution_number VARCHAR(3) CHECK(length(institution_number)=3) NOT NULL,
    account_number VARCHAR(7) CHECK(length(account_number)=7) NOT NULL,
    --
    -- Fields used in COBOL programs
    acc_id VARCHAR(15) GENERATED ALWAYS AS (transit_number || institution_number || account_number) STORED UNIQUE,
    owner_name VARCHAR(30) NOT NULL,
    balance DECIMAL(15, 2) DEFAULT 0.00 NOT NULL,
    daily_spent DECIMAL(15, 2) CHECK(daily_spent >= 0) DEFAULT 0.00 NOT NULL,
    daily_limit DECIMAL(15, 2) CHECK(daily_limit >= 0) DEFAULT 1000.00 NOT NULL,
    status CHAR(1) CHECK (status IN('A', 'F', 'C', 'D')) DEFAULT 'A' NOT NULL,
    --
    currency VARCHAR(3) DEFAULT 'CAD' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. User Table (Login identity, separate from accounts)
CREATE TABLE users(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_reference VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(60) NOT NULL,
    role VARCHAR(11) CHECK(role IN ('USER', 'ADMIN', 'SUPER_ADMIN')) NOT NULL,
    acc_id VARCHAR(15) REFERENCES accounts(acc_id) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Batch Runs Table (Batch processing records)
CREATE TABLE batch_runs(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    step_validate_rc INT,
    step_post_rc INT,
    step_report_rc INT,
    final_rc INT,
    log_file_path VARCHAR(255)
);

-- 4. Transactions Table (Transaction history)
--  NOTE: timestamp_str is in UNIX timestamp format; Set size for COBOL compatibility.
CREATE TABLE transactions(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- Fields used in COBOL programs
    end_to_end_id VARCHAR(35) NOT NULL UNIQUE,
    debtor_account_id VARCHAR(15) CHECK(length(debtor_account_id)=15) NOT NULL,
    creditor_account_id VARCHAR(15) CHECK(length(creditor_account_id)=15) NOT NULL,
    amount DECIMAL(15, 2) CHECK(amount > 0) NOT NULL,
    currency VARCHAR(3) DEFAULT 'CAD' NOT NULL,
    timestamp_str VARCHAR(13) NOT NULL,
    --
    status VARCHAR(20) CHECK(status IN('PENDING', 'BATCHED', 'SETTLED', 'REJECTED')) DEFAULT 'PENDING',
    reason_code VARCHAR(4),
    batch_run_id UUID REFERENCES batch_runs(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Audit Log Table
CREATE TABLE audit_logs(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID REFERENCES transactions(id),
    event_type VARCHAR(20) CHECK(event_type IN('SUBMITTED', 'BATCHED', 'VALIDATED', 'SETTLED', 'REJECTED', 'SKIPPED')) NOT NULL,
    message TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for performance
CREATE INDEX idx_transactions_end_to_end_id ON transactions(end_to_end_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_debtor_account ON transactions(debtor_account_id);
CREATE INDEX idx_transactions_creditor_account ON transactions(creditor_account_id);
CREATE INDEX idx_transactions_batch_run_id ON transactions(batch_run_id);
CREATE INDEX idx_audit_logs_transaction_id ON audit_logs(transaction_id);