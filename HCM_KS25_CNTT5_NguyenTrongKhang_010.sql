create database company_management_db;
use company_management_db;

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(12) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    join_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
 
CREATE TABLE insurance_packages (
    package_id VARCHAR(10) PRIMARY KEY,
    package_name VARCHAR(255) NOT NULL CHECK (package_name LIKE '%suc khoe%'
        OR package_name LIKE '%o to%'
        OR package_name LIKE '%nhan tho%'
        OR package_name LIKE '%du lich%'
        OR package_name LIKE '%tai nan%'),
    max_limit DECIMAL(18 , 2 ) NOT NULL CHECK (max_limit > 0),
    base_premium DECIMAL(18 , 2 ) NOT NULL CHECK (base_premium > 0)
);
 
CREATE TABLE policies (
    policy_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    package_id VARCHAR(10) NOT NULL,
    FOREIGN KEY (package_id)
        REFERENCES insurance_packages (package_id)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Active' , 'Expired', 'Cancelled')),
    FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    FOREIGN KEY (package_id)
        REFERENCES insurance_packages (package_id)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
 
CREATE TABLE claims (
    claim_id VARCHAR(10) PRIMARY KEY,
    policy_id VARCHAR(10) NOT NULL,
    claim_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    claim_amount DECIMAL(18 , 2 ) NOT NULL CHECK (claim_amount > 0),
    status VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending' , 'Approved', 'Rejected')),
    FOREIGN KEY (policy_id)
        REFERENCES policies (policy_id)
);
 
CREATE TABLE claim_processing_log (
    log_id VARCHAR(10) PRIMARY KEY,
    claim_id VARCHAR(10) NOT NULL,
    action_detail TEXT NOT NULL,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processor VARCHAR(255) NOT NULL,
    FOREIGN KEY (claim_id)
        REFERENCES claims (claim_id)
);
 
 insert into customers values
 ('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
 ('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@yahoo.com', '2024-03-10'),
 ('C003', 'Le Hoang Nam', '0903334445', 'nam.lh@outlook.com', '2025-05-20'),
 ('C004', 'Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
 ('C005', 'Hoang Thu Thao', '079998881', 'thao.ht@gmail.com', '2025-01-01');
 
 insert into insurance_packages values 
 ('PKG01', 'Bao hiem suc khoe gold', 500000000.00, 5000000.00),
 ('PKG02', 'Bao hiem o to Liberty', 1000000000.00, 15000000.00),
 ('PKG03', 'Bao hiem nhan tho An Binh', 2000000000.00, 25000000.00),
 ('PKG04', 'Bao hiem du lich quoc te', 100000000.00, 1000000.00),
 ('PKG05', 'Bao hiem tai nan 24/7', 200000000.00, 2500000.00);
 
 insert into policies values 
 ('POL101', 'C001', 'PKG01', '2024-01-15', '2025-01-15', 'Expired'),
 ('POL102', 'C002', 'PKG02', '2024-03-10', '2026-03-10', 'Active'),
 ('POL103', 'C003', 'PKG03', '2025-05-20', '2035-05-20', 'Active'),
 ('POL104', 'C004', 'PKG04', '2025-08-12', '2025-09-12', 'Expired'),
 ('POL105', 'C005', 'PKG05', '2026-01-01', '2027-01-01', 'Active');
 
 insert into claims values
('CLM901','POL102', '2024-06-15', 12000000, 'Approved'),
('CLM902','POL103', '2025-10-20', 50000000, 'Pending'),
('CLM903','POL101', '2024-11-05', 5500000, 'Approved'),
('CLM904','POL105', '2026-01-15', 2000000, 'Rejected'),
('CLM905','POL102', '2025-02-10', 120000000, 'Pending');

insert into claim_processing_log values
('L001', 'CLM901', 'Da nhan ho so hien truong','2024-06-15 09:00', 'Admin_01'),
('L002', 'CLM901', 'Chap nhan boi thuong xe tai nan','2024-06-20 14:30', 'Admin_01'),
('L003', 'CLM902', 'Dang tham dinh ho so benh an','2025-10-21 10:00', 'Admin_02'),
('L004', 'CLM904', 'Tu choi loi do co y khach hang','2026-01-16 16:00', 'Admin_03'),
('L005', 'CLM905', 'Da thanh toan qua chuyen khoan','2024-02-15 08:30', 'Admin_01');

alter table policies
add constraint ck_end_date check(end_date > start_date);
-- 1.3
-- cau 1
UPDATE insurance_packages 
SET 
    base_premium = base_premium * 1.15
WHERE
    max_limit > 500000000;
-- cau 2
DELETE FROM claim_processing_log 
WHERE
    recorded_at < '2025-06-20 00:00:00';

-- 1.4
-- cau 1
SELECT 
    *
FROM
    policies
WHERE
    status = 'Active'
        AND end_date BETWEEN '2026-01-01' AND '2026-12-31';

-- cau 2
SELECT 
    c.full_name, c.email
FROM
    customers c
        JOIN
    policies p ON c.customer_id = p.customer_id
WHERE
    c.full_name LIKE ('%Hoang%')
        OR c.full_name LIKE ('Hoang%')
        AND (p.end_date BETWEEN '2025-01-01' AND CURRENT_TIMESTAMP());
        
-- cau 3
SELECT 
    *
FROM
    claims
ORDER BY claim_amount DESC
LIMIT 3 OFFSET 1;

-- 1.5
-- cau 1 
SELECT 
    c.full_name, i.package_name, p.start_date, cl.claim_amount
FROM
    customers c
        JOIN
    policies p ON c.customer_id = p.customer_id
        JOIN
    insurance_packages i ON p.package_id = i.package_id
        LEFT JOIN
    claims cl ON cl.policy_id = p.policy_id;

-- cau 2

-- cau 3

 	
-- 1.6
-- cau 1
create index idx_policy_status on policies(status, start_date);

-- cau 2


-- 1.7
-- cau 1
alter table claims
add column claim_processing_log text;
delimiter //
create trigger trg_after_claim_approved
after update on claims
for each row
begin
	if new.status = 'Approved' then insert into claims (claim_processing_log) values ('Payment processed to customer');
    end if;
end //
delimiter ;

-- cau 2
delimiter //
create trigger prevent_del 
before delete on policies
for each row
begin
	if old.status = 'Active' then SIGNAL SQlSTATE '45000' set message_text = 'Khong duoc xoa vi dang active !' ;
    end if;
end //
delimiter ;

-- 1.8
-- cau 1







 
 
