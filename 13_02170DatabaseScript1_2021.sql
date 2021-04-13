DROP DATABASE IF EXISTS BloodBank;

CREATE DATABASE BloodBank;

use BloodBank;

DROP TABLE IF EXISTS BloodTranfusion;
DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS MedicalRecord;
DROP TABLE IF EXISTS StaffMember;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Donation;
DROP TABLE IF EXISTS Donor;
DROP TABLE IF EXISTS Hospital;
DROP TABLE IF EXISTS Compatibility;

# Table creation! Create Tables with Foreign Keys after the referenced tables are created!
CREATE TABLE Hospital
	(HospitalID			VARCHAR(10),
	 HospitalName		VARCHAR(50) NOT NULL,
	 HospitalAddress	VARCHAR(50) NOT NULL,
	 PRIMARY KEY(HospitalID)
	);

CREATE TABLE Compatibility
	(ReceiverBloodType		ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+'),
	 DonorBloodType	ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+'),
	 PRIMARY KEY(DonorBloodType, ReceiverBloodType)
	);

CREATE TABLE Donor
	(DonorID		VARCHAR(11),
	 DonorName		VARCHAR(20) NOT NULL,
	 HospitalID		VARCHAR(10) NOT NULL,
     BloodType		ENUM('O-','O+','B-','B+','A-','A+','AB-','AB+') NOT NULL,
	 PRIMARY KEY(DonorID),
     FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE NO ACTION,
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
	 HospitalID		VARCHAR(10) NOT NULL,
	 PRIMARY KEY(StaffID),
	 FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE CASCADE
	);

CREATE TABLE Donation
	(DonationID		VARCHAR(20),
     DonorID		VARCHAR(11) NOT NULL,
	 HospitalID		VARCHAR(10) NOT NULL,
     StaffID		VARCHAR(11) NOT NULL,
	 Amount  		DECIMAL(4,1) NOT NULL,
	 DonationDate	DATE NOT NULL,
     MedicalCheck   ENUM('Pass','Fail','Not Processed') NOT NULL,
     BeenUsed		BOOLEAN NOT NULL,
	 PRIMARY KEY(DonationID),
     FOREIGN KEY(DonorID) REFERENCES Donor(DonorID) ON DELETE NO ACTION,
     FOREIGN KEY(HospitalID) REFERENCES Hospital(HospitalID) ON DELETE NO ACTION,
     FOREIGN KEY(StaffID) REFERENCES StaffMember(StaffID) ON DELETE NO ACTION
	);

CREATE TABLE MedicalRecord
	(CaseNumber		VARCHAR(11),
	 PatientID		VARCHAR(11) NOT NULL,
	 Diognosis 		VARCHAR(30),
	 Status			VARCHAR(20),
	 PRIMARY KEY(CaseNumber),
	 FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE
	);

CREATE TABLE BloodTransfusion
	(DonationID		VARCHAR(20),
     CaseNumber		VARCHAR(11) NOT NULL,
	 TransfusionDate	DATE NOT NULL,
	 Amount  		DECIMAL(4,1) NOT NULL,
	 PRIMARY KEY(DonationID),
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

drop view if exists BloodAvailable;

create view BloodAvailable as select BloodType, sum(amount) from Donation natural join Donor
where DATEDIFF(CURDATE(), DonationDate) < 42 AND MedicalCheck='Pass' AND BeenUsed=False group by BloodType;

  INSERT Compatibility VALUES
('O-','O-'),
('O+','O-'),
('O+','O+'),
('B-','O-'),
('B-','B-'),
('B+','O-'),
('B+','O+'),
('B+','B-'),
('B+','B+'),
('A-','O-'),
('A-','A-'),
('A+','O-'),
('A+','O+'),
('A+','A-'),
('A+','A+'),
('AB-','O-'),
('AB-','B-'),
('AB-','A-'),
('AB-','AB-'),
('AB+','O-'),
('AB+','O+'),
('AB+','B-'),
('AB+','B+'),
('AB+','A-'),
('AB+','A+'),
('AB+','AB-'),
('AB+','AB+');

INSERT Hospital VALUES
('RIG','Rigshospitalet','Blegdamsvej 9, 2100 København'),
('OUH','Odense University Hospital','J. B. Winsløws Vej 4, 5000 Odense'),
('AUH','Aarhus University Hospital','Palle Juul-Jensens Blvd. 99, 8200 Aarhus');

INSERT Staffmember VALUES
('200176-7877','Maximilian Morgan','Nurse','2000-10-18','OUH'),
('301263-4269','Michael Kelly','Doctor','2008-05-30','AUH'),
('191288-4639','George Allen','Doctor','2017-02-13','AUH'),
('071275-9911','Blake Johnson','Nurse','2018-12-15','RIG'),
('090256-5702','Belinda Baker','Doctor','2016-05-05','RIG'),
('170154-1575','Daniel Mason','Doctor','2018-03-21','OUH'),
('060654-1215','Roman Baker','Nurse','2011-06-07','RIG'),
('010665-9244','Sofia Armstrong','Nurse','1999-09-22','AUH'),
('131051-9601','Tyler Gray','Nurse','1979-10-11','AUH'),
('110360-6592','Darcy Carter','Doctor','1995-04-29','AUH'),
('231092-2005','Leonardo Casey','Nurse','2017-03-28','RIG'),
('181260-9759','Kevin Foster','Doctor','1991-09-07','RIG'),
('240774-3104','Melissa Riley','Doctor','2008-12-07','AUH'),
('291185-1819','Sawyer Edwards','Nurse','2011-10-14','OUH'),
('131287-1835','George Cameron','Nurse','2014-08-16','RIG');

INSERT Donor VALUES
('080571-9917','Julian Harris','RIG','B+'),
('120792-2072','Jessica Martin','AUH','O-'),
('050292-5248','Caroline Barnes','AUH','A+'),
('160367-8705','Elian Hunt','AUH','AB+'),
('180885-3466','Carina Grant','RIG','A-'),
('081296-7389','Jared Rogers','AUH','O-'),
('300955-3610','Abigail Ellis','AUH','O-'),
('100177-1508','Evelyn Bailey','OUH','AB+'),
('101084-7995','Adrian Murphy','OUH','AB+'),
('130162-6988','Tara Kelly','RIG','O-'),
('140362-9109','Kellan Barrett','RIG','B-'),
('170289-5932','Sophia Chapman','OUH','AB-'),
('010701-6748','Chloe Hall','AUH','AB-'),
('061170-6517','Adam Armstrong','AUH','O-'),
('030275-3673','Ted Gray','AUH','B+'),
('090898-2704','Olivia Martin','AUH','A+'),
('150601-5375','Vincent Morrison','OUH','O+'),
('110955-8896','Emily Gray','AUH','AB+'),
('101257-6637','Kevin Harper','RIG','AB-'),
('120763-1328','Belinda Harper','OUH','AB-'),
('020487-2949','Lyndon Mason','RIG','O-'),
('231183-6423','Sawyer Cooper','AUH','B-'),
('060595-4865','Sam Riley','RIG','B-'),
('260850-2260','Elise Richards','RIG','O-'),
('160967-7683','Edward Harris','OUH','B-'),
('060164-1694','Julia Bennett','OUH','B+'),
('250482-3267','Derek Thomas','OUH','AB-'),
('220491-9520','Lydia Higgins','OUH','O+'),
('280695-5445','Adrian Nelson','OUH','A+'),
('050177-8167','Adrian Andrews','OUH','B-');


INSERT Donation VALUES
('OUH_08012021_794','220491-9520','OUH','200176-7877',500,'2021-01-08','Pass',True),
('AUH_03032021_999','050292-5248','AUH','301263-4269',500,'2021-03-03','Pass',True),
('AUH_10022021_161','090898-2704','AUH','301263-4269',500,'2021-02-10','Pass',True),
('RIG_19022021_601','020487-2949','RIG','090256-5702',500,'2021-02-19','Pass',True),
('AUH_12022021_439','300955-3610','AUH','301263-4269',500,'2021-02-12','Pass',True),
('RIG_18022021_815','080571-9917','RIG','231092-2005',500,'2021-02-18','Pass',False),
('AUH_23032021_821','010701-6748','AUH','110360-6592',500,'2021-03-23','Pass',False),
('AUH_17022021_643','120792-2072','AUH','010665-9244',500,'2021-02-17','Pass',True),
('RIG_23022021_974','140362-9109','RIG','181260-9759',500,'2021-02-23','Pass',False),
('RIG_01022021_224','080571-9917','RIG','090256-5702',500,'2021-02-01','Pass',False),
('AUH_24022021_230','050292-5248','AUH','191288-4639',500,'2021-02-24','Pass',True),
('OUH_11022021_384','050177-8167','OUH','291185-1819',500,'2021-02-11','Pass',False),
('AUH_30032021_127','030275-3673','AUH','131051-9601',500,'2021-03-30','Pass',False),
('AUH_14012021_752','231183-6423','AUH','110360-6592',500,'2021-01-14','Pass',False),
('OUH_17032021_734','060164-1694','OUH','200176-7877',500,'2021-03-17','Pass',False),
('OUH_19022021_046','100177-1508','OUH','291185-1819',500,'2021-02-19','Fail',False),
('OUH_16012021_027','250482-3267','OUH','291185-1819',500,'2021-01-16','Pass',False),
('AUH_31032021_976','090898-2704','AUH','110360-6592',500,'2021-03-31','Pass',False),
('AUH_05012021_786','050292-5248','AUH','110360-6592',500,'2021-01-05','Pass',False),
('RIG_31012021_110','060595-4865','RIG','181260-9759',500,'2021-01-31','Pass',False),
('AUH_08012021_564','110955-8896','AUH','110360-6592',500,'2021-01-08','Pass',False),
('AUH_31012021_185','050292-5248','AUH','010665-9244',500,'2021-01-31','Pass',False),
('OUH_20022021_259','160967-7683','OUH','170154-1575',500,'2021-02-20','Pass',False),
('OUH_13032021_429','170289-5932','OUH','291185-1819',500,'2021-03-13','Pass',False),
('AUH_23022021_708','081296-7389','AUH','110360-6592',500,'2021-02-23','Pass',False),
('AUH_08032021_703','231183-6423','AUH','010665-9244',500,'2021-03-08','Pass',False),
('AUH_20012021_167','010701-6748','AUH','301263-4269',500,'2021-01-20','Pass',False),
('AUH_31032021_530','090898-2704','AUH','010665-9244',500,'2021-03-31','Pass',False),
('OUH_24012021_140','220491-9520','OUH','170154-1575',500,'2021-01-24','Pass',False),
('OUH_30032021_551','220491-9520','OUH','291185-1819',500,'2021-03-30','Pass',False),
('OUH_16032021_599','220491-9520','OUH','200176-7877',500,'2021-03-16','Pass',False),
('OUH_18022021_206','060164-1694','OUH','170154-1575',500,'2021-02-18','Pass',False),
('AUH_19012021_429','090898-2704','AUH','010665-9244',500,'2021-01-19','Pass',False),
('AUH_01032021_595','300955-3610','AUH','131051-9601',500,'2021-03-01','Fail',False),
('RIG_10012021_878','260850-2260','RIG','060654-1215',500,'2021-01-10','Pass',False),
('OUH_06012021_479','280695-5445','OUH','291185-1819',500,'2021-01-06','Pass',False),
('OUH_25012021_795','280695-5445','OUH','291185-1819',500,'2021-01-25','Fail',False),
('OUH_02022021_174','050177-8167','OUH','291185-1819',500,'2021-02-02','Fail',False),
('AUH_24022021_094','081296-7389','AUH','240774-3104',500,'2021-02-24','Pass',False),
('AUH_03022021_854','050292-5248','AUH','010665-9244',500,'2021-02-03','Pass',False),
('AUH_13022021_008','231183-6423','AUH','010665-9244',500,'2021-02-13','Pass',False),
('RIG_16032021_761','020487-2949','RIG','060654-1215',500,'2021-03-16','Pass',False),
('RIG_16012021_905','140362-9109','RIG','090256-5702',500,'2021-01-16','Pass',False),
('AUH_15012021_449','061170-6517','AUH','131051-9601',500,'2021-01-15','Pass',False),
('AUH_09032021_964','160367-8705','AUH','240774-3104',500,'2021-03-09','Pass',False);

INSERT Patient VALUES
('150399-6553','Eddy Gibson','Nørretorv 15B, 8700 Horsens','AB-','RIG'),
('010478-1329','Martin Mitchell','Krekærvangen 20, 8340 Malling','A-','OUH'),
('230555-6446','Olivia Ross','Ørestads Boulevard 46B, 2300 København S','B+','OUH'),
('190881-5568','Sydney Gray','Alberts Have 29, 2620 Albertslund','AB+','AUH'),
('281251-1993','Jared Carroll','Skaarupsundvænget 2, 5700 Svendborg','O-','AUH'),
('130283-5114','Rubie Williams','Hf. Dahlia 101, 2650 Hvidovre','AB+','AUH'),
('161076-6243','Carl Evans','Dalhaven 32, 3660 Stenløse','B+','RIG'),
('150866-6123','Jordan Edwards','Mejlstedvej 55, 9380 Vestbjerg','B-','OUH'),
('131276-7179','Miller Watson','Kærhaven 48, 6800 Varde','O-','RIG'),
('260101-3153','Eric Kelly','Cypressen 109, 2635 Ishøj','A+','OUH'),
('020374-4911','Alfred Casey','Guldmajsvej 30, 9990 Skagen','A-','OUH'),
('170189-2588','Gianna Walker','Bågø Havekoloni 133, 5000 Odense C','B+','RIG'),
('111279-4677','Marcus Ross','Elmebjergvej 17F, 4180 Sorø','A-','OUH'),
('040357-6516','Penelope Hunt','Slangerupgade 42F, 3400 Hillerød','A+','AUH'),
('291200-8390','Deanna West','Kærgårdsvej 28B, 6800 Varde','A+','OUH'),
('061160-1554','Alissa Crawford','Knøsgårdvej 106, 9440 Aabybro','A+','AUH'),
('100478-4007','Carl Hawkins','Hf. Helgetoften 55, 5800 Nyborg','B+','OUH'),
('030957-6657','Alfred Reed','Dr Louisesvej 50, 7800 Skive','A-','AUH'),
('181087-5782','Valeria Murphy','Ole Lund Kirkegaa. A 31, 8200 Aarhus N','B-','AUH'),
('100991-6675','Richard Murphy','Høegh Guldbergs Gade 15D, 8700 Horsens','AB-','AUH');

INSERT MedicalRecord VALUES
('70453240','150399-6553','Anemia','Released'),
('55436777','010478-1329','Infection','Released'),
('49516872','230555-6446','Cancer','Released'),
('34038988','190881-5568','Anemia','Released'),
('54497191','281251-1993','Acute blood loss','Released'),
('51935352','130283-5114','Cancer','Released'),
('82898362','161076-6243','Acute blood loss','Stable'),
('74249891','150866-6123','Anemia','Acute'),
('54676066','131276-7179','Acute blood loss','Stable'),
('76841198','260101-3153','Infection','Acute'),
('34809600','020374-4911','Cancer','Released'),
('27243783','170189-2588','Cancer','Stable'),
('32861481','111279-4677','Cancer','Acute'),
('14038269','040357-6516','Acute blood loss','Stable'),
('88256544','291200-8390','Anemia','Released'),
('50185260','061160-1554','Acute blood loss','Acute'),
('10318484','100478-4007','Infection','Released'),
('36696850','030957-6657','Cancer','Released'),
('69622500','181087-5782','Infection','Released'),
('21909846','100991-6675','Infection','Acute');

    INSERT Assignment VALUES
('231092-2005','70453240','2021-02-03'),
('170154-1575','55436777','2021-01-08'),
('231092-2005','49516872','2021-01-20'),
('301263-4269','34038988','2021-03-13'),
('191288-4639','54497191','2021-02-28'),
('181260-9759','51935352','2021-01-24'),
('240774-3104','51935352','2021-03-12'),
('090256-5702','82898362','2021-02-19'),
('200176-7877','82898362','2021-01-18'),
('131051-9601','74249891','2021-02-15'),
('240774-3104','54676066','2021-01-09'),
('301263-4269','76841198','2021-03-29'),
('110360-6592','76841198','2021-01-15'),
('181260-9759','34809600','2021-02-20'),
('131051-9601','27243783','2021-03-09'),
('170154-1575','32861481','2021-02-07'),
('060654-1215','14038269','2021-02-10'),
('131051-9601','88256544','2021-03-29'),
('181260-9759','50185260','2021-03-23'),
('191288-4639','10318484','2021-03-09'),
('231092-2005','10318484','2021-02-28'),
('291185-1819','36696850','2021-03-06'),
('131287-1835','36696850','2021-03-24'),
('231092-2005','69622500','2021-01-20'),
('191288-4639','69622500','2021-03-01'),
('071275-9911','21909846','2021-03-06');



INSERT BloodTransfusion VALUES
('RIG_19022021_601','70453240','2021-02-25',500),
('AUH_03032021_999','34038988','2021-03-17',500),
('AUH_12022021_439','54497191','2021-03-15',500),
('OUH_08012021_794','82898362','2021-01-20',500),
('AUH_17022021_643','54676066','2021-03-11',500),
('AUH_10022021_161','14038269','2021-03-17',500),
('AUH_24022021_230','88256544','2021-03-31',500);
