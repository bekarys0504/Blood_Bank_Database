DROP DATABASE IF EXISTS BloodBank;

CREATE DATABASE BloodBank;

use BloodBank;

DROP TABLE IF EXISTS Donor;
DROP TABLE IF EXISTS Donation;
DROP TABLE IF EXISTS Hospital;
DROP TABLE IF EXISTS BloodTranfusion;
DROP TABLE IF EXISTS StaffMember;
DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS MedicalRecord;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Compatibility;

# Table creation! Create Tables with Foreign Keys after the referenced tables are created!
CREATE TABLE Hospital
	(HospitalID			VARCHAR(10),
	 HospitalName		VARCHAR(50) NOT NULL, 
	 HospitalAddress	VARCHAR(50) NOT NULL,
	 PRIMARY KEY(HospitalID)
	);

CREATE TABLE Compatibility
	(BloodType		ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+'),
	 CanGive		VARCHAR(5),
	 CanReceive		VARCHAR(5),
	 PRIMARY KEY(BloodType)
	);
    
CREATE TABLE Donor
	(DonorID		VARCHAR(11),
	 DonorName		VARCHAR(20) NOT NULL,
	 HospitalID		VARCHAR(10),
     BloodType		ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+') NOT NULL,
     lastDonation   DATE,
	 PRIMARY KEY(DonorID),
     FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE SET NULL,
     FOREIGN KEY(BloodType) REFERENCES Compatibility(BloodType) ON DELETE CASCADE
	);

CREATE TABLE Patient
	(PatientID				VARCHAR(11), 
	 PatientName			VARCHAR(20) NOT NULL,
	 PatientAdress			VARCHAR(50), 
	 BloodType				ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+') NOT NULL,
	 HospitalID				VARCHAR(10),
	 PRIMARY KEY(PatientID),
     FOREIGN KEY(BloodType) REFERENCES Compatibility(BloodType) ON DELETE CASCADE,
	 FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE SET NULL
	);

CREATE TABLE Donation
	(DonationID		VARCHAR(20), 
     DonorID		VARCHAR(11) NOT NULL,
	 HospitalID		VARCHAR(10),
	 Amount  		DECIMAL(4,1) NOT NULL, 
	 DonationDate	DATE NOT NULL,
     MedicalCheck   ENUM('Pass','Fail','Not Processed') NOT NULL,
	 PRIMARY KEY(DonationID),
     FOREIGN KEY(DonorID) REFERENCES Donor(DonorID) ON DELETE NO ACTION,
     FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE SET NULL
	);

CREATE TABLE MedicalRecord
	(CaseNumber		VARCHAR(11), 
	 PatientID		VARCHAR(11), 
	 Disease 		VARCHAR(30),
	 Status			VARCHAR(20),
	 PRIMARY KEY(CaseNumber),
	 FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE
	);

CREATE TABLE BloodTranfusion
	(BloodTranfusionID
    DonationID		VARCHAR(11), 
     CaseNumber		VARCHAR(11), 
	 TranfusionDate	DATE NOT NULL,
	 Amount  		DECIMAL(4,1) NOT NULL, 
	 PRIMARY KEY(DonationID, CaseNumber),
     FOREIGN KEY(DonationID) REFERENCES Donation(DonationID) ON DELETE no action,
     FOREIGN KEY(CaseNumber) REFERENCES MedicalRecord(CaseNumber) ON DELETE no action
	);

CREATE TABLE StaffMember
	(StaffID		VARCHAR(11), 
     StaffName		VARCHAR(20) NOT NULL,
	 Position		VARCHAR(20) NOT NULL,
	 HiringDate		DATE NOT NULL,
	 HospitalID		VARCHAR(10),
	 PRIMARY KEY(StaffID),
	 FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE CASCADE
	);

CREATE TABLE Assignment
	(StaffID		VARCHAR(11), 
     CaseNumber		VARCHAR(11),
	 AssignmentDate		DATE,
	 PRIMARY KEY(StaffID, CaseNumber),
     FOREIGN KEY(StaffID) REFERENCES StaffMember(StaffID) ON DELETE CASCADE,
     FOREIGN KEY(CaseNumber) REFERENCES MedicalRecord(CaseNumber) ON DELETE CASCADE
	);
