use BloodBank;

SET SQL_SAFE_UPDATES = 0;

select * from Patient;

Update Patient set HospitalID = 
case
when HospitalID = 'OUH' Then 'RIG'
else HospitalID
end;

select * from Patient;

select * from Donation;

delete from Donation where HospitalID = 'AUH' and MedicalCheck = 'Fail';