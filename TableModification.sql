use BloodBank;

SET SQL_SAFE_UPDATES = 0;

select * from Patient;

UPDATE Patient SET HospitalID = 
CASE
WHEN HospitalID = 'OUH' THEN 'RIG'
ELSE HospitalID
END;

select * from Patient;

select * from Donation;

delete from Donation where HospitalID = 'AUH' and MedicalCheck = 'Fail';