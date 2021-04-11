use BloodBank;

SELECT HospitalID, DonorName FROM Donor ORDER BY HospitalID, DonorName;

SELECT HospitalID, SUM(AMOUNT) FROM Donation GROUP BY HospitalID;

SELECT DonorName, SUM(AMOUNT) FROM Donation NATURAL JOIN Donor GROUP BY DonorID HAVING SUM(AMOUNT) > 1000;

SELECT Diognosis, SUM(AMOUNT) FROM BloodTransfusion NATURAL JOIN MedicalRecord GROUP BY Diognosis;

SELECT HospitalID, SUM(AMOUNT) FROM Donation GROUP BY HospitalID;

select * from BloodTransfusion;