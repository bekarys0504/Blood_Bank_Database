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