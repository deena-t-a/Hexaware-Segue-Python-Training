USE HospitalDB;

-- Seed Patients
INSERT INTO Patients (patient_name, address) VALUES
('Aarav Mehta', 'Mumbai'), ('Pooja Sharma', 'Pune'), 
('Rahul Verma', 'Delhi'), ('Ananya Iyer', 'Bangalore');

-- Seed Departments
INSERT INTO Departments (department_name) VALUES
('Cardiology'), ('Neurology'), ('Orthopedics');

-- Seed Doctors
INSERT INTO Doctors (doctor_name, department_id) VALUES
('Dr. R. K. Gupta', 1), ('Dr. Sunita Rao', 2), ('Dr. Vikram Seth', 3);

-- Seed Visits (Default status 'Open' applied)
INSERT INTO Visits (patient_id, doctor_id, visit_date) VALUES
(1, 1, '2026-10-15'),
(2, 2, '2026-10-20'),
(3, 3, '2026-11-02'),
(4, 1, '2026-11-05');

-- Seed VisitBilling (formerly Billing)
INSERT INTO VisitBilling (visit_id, bill_amount) VALUES
(1, 1500.00), (2, 3500.50), (3, 2000.00), (4, 1200.00);


-- TASK 4: REQUIRED WHERE CLAUSE QUERIES

-- 1. Retrieve patients visited in a given month (e.g., October 2026)
SELECT p.patient_name, v.visit_date, v.status
FROM Patients p
JOIN Visits v ON p.patient_id = v.patient_id
WHERE v.visit_date >= '2026-10-01' AND v.visit_date <= '2026-10-31';

-- 2. Retrieve doctors of a specific department (e.g., Cardiology)
SELECT d.doctor_name, dept.department_name
FROM Doctors d
JOIN Departments dept ON d.department_id = dept.department_id
WHERE dept.department_name = 'Cardiology';
