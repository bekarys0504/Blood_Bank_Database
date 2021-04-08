use BloodBank;

drop view BloodAvailable;

create view BloodAvailable as select BloodType, sum(amount) from Donation natural join Donor
where DATEDIFF(CURDATE(), DonationDate) AND MedicalCheck='Pass' AND BeenUsed='Unused' group by BloodType;

select * from BloodAvailable;