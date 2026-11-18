CREATE DATABASE HospitalDB;

USE HospitalDB;


-- 1. Patients Table
CREATE TABLE Patients (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL
);

-- 2. Departments Table
CREATE TABLE Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Doctors Table
CREATE TABLE Doctors (
    doctor_id INT IDENTITY(1,1) PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT FK_Doctor_Department FOREIGN KEY (department_id) 
        REFERENCES Departments(department_id) ON DELETE CASCADE
);

-- 4. Visits Table (Default status of 'Open', check constraint for visit date)
CREATE TABLE Visits (
    visit_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL CHECK (visit_date <= GETDATE()),
    status VARCHAR(20) DEFAULT 'Open',
    CONSTRAINT FK_Visit_Patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT FK_Visit_Doctor FOREIGN KEY (doctor_id) 
        REFERENCES Doctors(doctor_id) ON DELETE CASCADE
);

-- 5. Billing Table (Non-negative bill amounts check constraint)
CREATE TABLE Billing (
    billing_id INT IDENTITY(1,1) PRIMARY KEY,
    visit_id INT NOT NULL UNIQUE,
    bill_amount DECIMAL(10,2) NOT NULL CHECK (bill_amount >= 0),
    CONSTRAINT FK_Billing_Visit FOREIGN KEY (visit_id) 
        REFERENCES Visits(visit_id) ON DELETE CASCADE
);
