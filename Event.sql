USE BloodBank;

set global event_scheduler = 0;

drop event if exists donationcleanup;

CREATE EVENT DonationCleanup
ON SCHEDULE EVERY 1 WEEK
DO DELETE FROM Donation 
WHERE ((DATEDIFF(CURDATE(), DonationDate) > 42 OR MedicalCheck='Fail') AND BeenUsed=False);

select * from donation;
set global event_scheduler = 1;
select * from donation order by DonationDate;

