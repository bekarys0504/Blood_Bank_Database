use BloodBank;

SELECT HospitalID, DonorName FROM Donor ORDER BY HospitalID, DonorName;

SELECT HospitalID, SUM(AMOUNT) FROM Donation GROUP BY HospitalID;

SELECT DonorName, SUM(AMOUNT) FROM Donation NATURAL JOIN Donor GROUP BY DonorID HAVING SUM(AMOUNT) > 1000;

SELECT Diognosis, SUM(AMOUNT) FROM BloodTransfusion NATURAL JOIN MedicalRecord GROUP BY Diognosis;

SELECT HospitalID, SUM(AMOUNT) FROM Donation GROUP BY HospitalID;

select * from BloodTransfusion;

SET SQL_SAFE_UPDATES = 0;

UPDATE Patient SET HospitalID =
CASE
WHEN HospitalID = 'OUH' THEN 'RIG'
ELSE HospitalID
END;

DELETE FROM Donation WHERE HospitalID = 'AUH' AND MedicalCheck = 'Fail';

/*FUNCTIONS*/

DROP FUNCTION IF EXISTS canDonorDonate;

Delimiter //
CREATE FUNCTION canDonorDonate(vDonorId VARCHAR(20)) RETURNS BOOL
BEGIN
    DECLARE vDaysSinceLastDonation INT;
    DECLARE vBloodCooldown INT;
    DECLARE vLastDonation INT;
    SET vBloodCooldown = 56;
    SELECT MAX(donationDate) INTO vLastDonation FROM donation WHERE donorID = vDonorId;
    SELECT datediff(current_timestamp(), vLastDonation) INTO vDaysSinceLastDonation;
    IF vDaysSinceLastDonation > vBloodCooldown OR isnull(vLastDonation)
    THEN RETURN TRUE;
    ELSE
    RETURN FALSE;
    END IF;
    END //
DELIMITER ;

    SELECT canDonorDonate("080571-9917");

/*TRIGGERS*/

DROP TRIGGER IF EXISTS DonationInsertCheckDonor;

DELIMITER //
CREATE TRIGGER DonationInsertCheckDonor
BEFORE INSERT ON Donation FOR EACH ROW
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Donor WHERE NEW.DonorID = Donor.DonorID)
	THEN SIGNAL SQLSTATE 'HY000'
			SET MYSQL_ERRNO = 1525,
            MESSAGE_TEXT = "Donor does not exist in the database. Ensure that the DonorID is valid and that the donor is registered in the database.";
	END IF;
END //
DELIMITER ;

-- Insert with wrong donorID
INSERT Donation VALUES
('OUH_08012021_794','22d91-9520','OUH','200176-7877',500,'2021-01-08','Pass',True);

SHOW WARNINGS;
SELECT * FROM Donation;

-- Insert with correct donorID
INSERT Donation VALUES
('AUH_12022d021_439','300955-3610','AUH','301263-4269',500,'2021-02-12','Pass',True);

SELECT * FROM Donation;

/*EVENTS*/

SET GLOBAL EVENT_SCHEDULER = 0;

DROP EVENT IF EXISTS DonationCleanup;

CREATE EVENT DonationCleanup
ON SCHEDULE EVERY 1 day
DO DELETE FROM Donation WHERE ((DATEDIFF(CURDATE(), DonationDate) > 42 OR MedicalCheck='Fail') AND BeenUsed=False);

SET GLOBAL EVENT_SCHEDULER = 1;

SELECT * FROM Donation ORDER BY DonationDate;

/*PROCEDURES*/

DROP PROCEDURE IF EXISTS CheckValidity;

DELIMITER //
CREATE PROCEDURE CheckValidity
(IN vDonationID VARCHAR(20), OUT vValid BOOLEAN)
BEGIN
    IF EXISTS (SELECT * FROM Donation WHERE DonationID = vDonationID AND DATEDIFF(CURDATE(), DonationDate) < 42 AND MedicalCheck='Pass' AND BeenUsed=False) THEN
        SET vValid = TRUE;
    ELSE
        SET vValid = FALSE;
	END IF;
END//
DELIMITER ;


CALL CheckValidity('OUH_19022021_046', @Valid);
CALL CheckValidity('AUH_14012021_752', @Valid);


CALL CheckValidity('AUH_23032021_821', @Valid);

Select @Valid;

SELECT * FROM Donation WHERE DonationID = 'AUH_30032021_127' AND DATEDIFF(CURDATE(), DonationDate) < 42 AND MedicalCheck='Pass' AND BeenUsed=False
