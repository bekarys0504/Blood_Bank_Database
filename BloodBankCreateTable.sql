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
	(DonorBloodType		ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+'),
	 ReceiverBloodType	ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+'),
	 PRIMARY KEY(DonorBloodType, ReceiverBloodType)
	);
    
CREATE TABLE Donor
	(DonorID		VARCHAR(11),
	 DonorName		VARCHAR(20) NOT NULL,
	 HospitalID		VARCHAR(10),
     BloodType		ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+') NOT NULL,
     lastDonation   DATE,
	 PRIMARY KEY(DonorID),
     FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE SET NULL,
     FOREIGN KEY(BloodType) REFERENCES Compatibility(DonorBloodType) ON DELETE CASCADE
	);

CREATE TABLE Patient
	(PatientID				VARCHAR(11), 
	 PatientName			VARCHAR(20) NOT NULL,
	 PatientAdress			VARCHAR(50), 
	 BloodType				ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+') NOT NULL,
	 HospitalID				VARCHAR(10),
	 PRIMARY KEY(PatientID),
	 FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE SET NULL,
     FOREIGN KEY(BloodType) REFERENCES Compatibility(DonorBloodType) ON DELETE CASCADE
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

CREATE TABLE Donation
	(DonationID		VARCHAR(20), 
     DonorID		VARCHAR(11) NOT NULL,
	 HospitalID		VARCHAR(10),
     StaffID		VARCHAR(11) NOT NULL,
	 Amount  		DECIMAL(4,1) NOT NULL, 
	 DonationDate	DATE NOT NULL,
     MedicalCheck   ENUM('Pass','Fail','Not Processed') NOT NULL,
     BeenUsed		BOOLEAN,
	 PRIMARY KEY(DonationID),
     FOREIGN KEY(DonorID) REFERENCES Donor(DonorID) ON DELETE NO ACTION,
     FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE SET NULL,
     FOREIGN KEY(StaffID) REFERENCES StaffMember(StaffID) ON DELETE NO ACTION
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
	(DonationID		VARCHAR(11), 
     CaseNumber		VARCHAR(11), 
	 TranfusionDate	DATE NOT NULL,
	 Amount  		DECIMAL(4,1) NOT NULL, 
	 PRIMARY KEY(DonationID, CaseNumber),
     FOREIGN KEY(DonationID) REFERENCES Donation(DonationID) ON DELETE no action,
     FOREIGN KEY(CaseNumber) REFERENCES MedicalRecord(CaseNumber) ON DELETE no action
	);

CREATE TABLE Assignment
	(StaffID		VARCHAR(11), 
     CaseNumber		VARCHAR(11),
	 AssignmentDate		DATE,
	 PRIMARY KEY(StaffID, CaseNumber),
     FOREIGN KEY(StaffID) REFERENCES StaffMember(StaffID) ON DELETE CASCADE,
     FOREIGN KEY(CaseNumber) REFERENCES MedicalRecord(CaseNumber) ON DELETE CASCADE
	);
    
    /* I have not actually tested my functions.. I had a really hard time making the insert from the python scripth work */
	delimiter //
    create function lastDonation(vDonorId VARCHAR(20)) returns bool
    begin
    Declare vDaysSinceLastDonation INT;
    Declare vfourthOfAYear
    select donationDate from donation as vLastDonation
    where donorId = vDonerId
    select GETDATE() as vToday;
    select datediff(day, vLastDonation, vToday) into vDaysSinceLastDonation;
    if 
    vDaysSinceLastDonation < vfourthOfAYear;
    then 
    return true;
    else
    return false;
	end
    delimiter ;

	delimiter //
    create function isDonationDeleteable(vDonationID varchar(20)) returns bool
    begin
    declare vIsInvalid enum('Pass','Fail','Not Processed');
    declare vToday date;
	declare vIsUsed bool;
    declare vDonationAge int;
    select GETDATE() as vToday;
    select BeenUsed into IsUsed from donation where donationID = vDonationID;
    select DonationDate as vDonationDate from donation where donationID = vDonationID;
    select MedicalCheck into vIsInvalid from donation where donation = vDonationID;
    SET vDonationAge = datediff(day, vDonationDate, vToday);
    if 
    vDonationAge < 60 or vIsUsed = true or vIsInvalied = 'Fail' 
    then
    return true;
    else 
    return false;
    end
    delimiter ;
    
    
