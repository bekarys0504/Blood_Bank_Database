USE BloodBank;

set global event_scheduler = 0;

drop event if exists donationcleanup;

CREATE EVENT DonationCleanup
ON SCHEDULE EVERY 1 day
do delete from Donation where ((DATEDIFF(CURDATE(), DonationDate) > 42 or MedicalCheck='Fail') AND BeenUsed=False);

select * from donation;
set global event_scheduler = 1;
select * from donation order by DonationDate;

