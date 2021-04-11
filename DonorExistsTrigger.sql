USE BloodBank;

DELIMITER //
CREATE TRIGGER DonationInsertCheckDonor
BEFORE INSERT ON Donation FOR EACH ROW
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Donor where NEW.DonorID = Donor.DonorID)
	THEN SIGNAL SQLSTATE 'HY000'
			SET MYSQL_ERRNO = 1525,
            MESSAGE_TEXT = "Donor does not exist in database.";
	END IF;
END //
DELIMITER ;

-- Insert wrong donorID
INSERT Donation VALUES
('OUH_08012021_794','22d91-9520','OUH','200176-7877',500,'2021-01-08','Pass',True);

select * from donation;