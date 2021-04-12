USE BloodBank;

drop trigger if exists DonationInsertCheckDonor;

DELIMITER //
CREATE TRIGGER DonationInsertCheckDonor
BEFORE INSERT ON Donation FOR EACH ROW
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Donor where NEW.DonorID = Donor.DonorID)
	THEN SIGNAL SQLSTATE 'HY000'
			SET MYSQL_ERRNO = 1525,
            MESSAGE_TEXT = "Donor does not exist in the database. Ensure that the DonorID is valid and that the donor is registered in the database.";
	END IF;
END //
DELIMITER ;

-- Insert with wrong donorID
INSERT Donation VALUES
('OUH_08012021_794','22d91-9520','OUH','200176-7877',500,'2021-01-08','Pass',True);

show warnings;
select * from donation;

-- Insert with correct donorID
INSERT Donation VALUES
('AUH_12022d021_439','300955-3610','AUH','301263-4269',500,'2021-02-12','Pass',True);

select * from donation;

