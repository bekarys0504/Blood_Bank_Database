use BloodBank;

drop view BloodAvailable;

create view BloodAvailable as select BloodType, sum(amount) from Donation natural join Donor
where DATEDIFF(CURDATE(), DonationDate) > 42 AND MedicalCheck='Pass' AND BeenUsed=False group by BloodType;

select * from BloodAvailable;