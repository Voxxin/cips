-- Password for all users: password
-- Password hashes are made using BCRYPT

INSERT INTO accounts(id, transit_number, institution_number, account_number, owner_name, balance, daily_limit, status, currency, created_at) VALUES
-- SUPER_ADMIN Account
('b0000000-9999-0000-0000-000000000000', '00001', '999', '9999000', 'SUPER ADMINISTRATOR', 1000000.00, 1000000.00, 'A', 'CAD', '1999-01-08 04:05:06 -08:00'),

-- Dummy Users
('b0000000-0000-0000-0000-000000000001', '00001', '999', '0000001', 'Boyd Stevens', 50.00, 3000.00, 'A', 'CAD', '1999-01-08 04:05:06 -08:00'),
('b0000000-0000-0000-0000-000000000002', '00001', '999', '0000002', 'Sara Myers', 10053.58, 1000.00, 'A', 'CAD', '1999-01-08 04:05:06 -08:00'),
('b0000000-0000-0000-0000-000000000003', '00001', '999', '0000003', 'Jade Herrera', 1000468.23, 300.00, 'A', 'CAD', '1999-01-08 04:05:06 -08:00'),
('b0000000-0000-0000-0000-000000000004', '00001', '999', '0000004', 'Jim Matthews', 5000.16, 100.00, 'C', 'CAD', '1999-01-08 04:05:06 -08:00'),
('b0000000-0000-0000-0000-000000000005', '00001', '999', '0000005', 'Ellis Stevens', 25.00, 100.00, 'F', 'CAD', '1999-01-08 04:05:06 -08:00');

INSERT INTO users(id, user_reference, password_hash, acc_id, role) VALUES
-- SUPER_ADMIN Account
('a0000000-9999-0000-0000-000000000000', 'super_admin', '$2a$12$G3Idv9xYb/tkhxZ2EOMBae8qMc/0FGbbquNHeapQ9u/KarV7QoX2S', '000019999999000', 'SUPER_ADMIN'),

-- Dummy Users
('a0000000-0000-0000-0000-000000000001', 'dummy_user1', '$2a$12$G3Idv9xYb/tkhxZ2EOMBae8qMc/0FGbbquNHeapQ9u/KarV7QoX2S', '000019990000001', 'USER'),
('a0000000-0000-0000-0000-000000000002', 'dummy_user2', '$2a$12$G3Idv9xYb/tkhxZ2EOMBae8qMc/0FGbbquNHeapQ9u/KarV7QoX2S', '000019990000002', 'USER'),
('a0000000-0000-0000-0000-000000000003', 'dummy_user3', '$2a$12$G3Idv9xYb/tkhxZ2EOMBae8qMc/0FGbbquNHeapQ9u/KarV7QoX2S', '000019990000003', 'USER'),
('a0000000-0000-0000-0000-000000000004', 'dummy_user4', '$2a$12$G3Idv9xYb/tkhxZ2EOMBae8qMc/0FGbbquNHeapQ9u/KarV7QoX2S', '000019990000004', 'USER'),
('a0000000-0000-0000-0000-000000000005', 'dummy_user5', '$2a$12$G3Idv9xYb/tkhxZ2EOMBae8qMc/0FGbbquNHeapQ9u/KarV7QoX2S', '000019990000005', 'USER');
