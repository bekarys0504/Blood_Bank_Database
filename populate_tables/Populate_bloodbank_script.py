#!/usr/bin/env python3
# Author: Mathias Rahbek-Borre (s183447)
# Date: 31-3-2021
# Course: Database systems
import random
import datetime
import re


def rand_date(start_date, end_date):
    time_between_dates = end_date - start_date
    days_between_dates = time_between_dates.days
    random_number_of_days = random.randrange(days_between_dates)
    random_date = start_date + datetime.timedelta(days=random_number_of_days)
    return random_date


def rand_cpr(gender, start_date = datetime.date(1950, 1, 1), end_date = datetime.date(2002, 1, 1)):
    new_date = rand_date(start_date, end_date).strftime("%d%m%y")

    last_cpr_num = random.randrange(1000, 9999, 2)

    if gender == "Male":
        last_cpr_num += 1

    return "{}-{}".format(new_date, last_cpr_num)


def list_to_SQL_list(list, outfilename, SQL_table_name):
    string = "INSERT {} VALUES\n".format(SQL_table_name)
    for row in list:
        string2 = "("

        for item in row:
            string2 += "\'" + str(item) + "\',"

        string += string2[:-1] + "),\n"

    string = string[:-2] + ";"

    outfile = open(outfilename, "w")
    print(string, file=outfile)
    outfile.close()

    return


random.seed(1)

## Populate Hospital
hospitals = [["RIG", "Rigshospitalet", "Blegdamsvej 9, 2100 København"],
            ["OUH", "Odense University Hospital", "J. B. Winsløws Vej 4, 5000 Odense"],
            ["AUH", "Aarhus University Hospital", "Palle Juul-Jensens Blvd. 99, 8200 Aarhus"]]

hospital_file = "hospital_pop.txt"
list_to_SQL_list(hospitals, hospital_file, "Hospital")

names = open("random_names_w_gender.csv", "r")
name_list = [re.sub('\"',"",line).split(",") for line in names]
names.close()

bloodtypes = ["O-","O+","A-","A+","B-","B+","AB-","AB+"]

## Populate Donor
n = 20
donor_file = "donor_pop.txt"
donor_list = []
used_cprs = []
for _ in range(n):
    name = name_list.pop()
    name, gender = " ".join(name[:2]), name[2].strip()

    cpr = rand_cpr(gender)
    while cpr in used_cprs:
        cpr = rand_cpr(gender)
    used_cprs.append(cpr)

    hos_id = random.choice(hospitals)[0]
    blood_type = random.choice(bloodtypes)

    last_donation = "No donations yet."

    row = [cpr, name, hos_id, blood_type, last_donation]
    donor_list.append(row)

list_to_SQL_list(donor_list, donor_file, "Donor")

## Populate Patient
n = 20
patient_file = "patient_pop.txt"
patient_list = []

infile = open("adresses_short.txt","r")
adresses = []
for line in infile:
    if line.strip() not in adresses:
        adresses.append(line.strip())
infile.close

for _ in range(n):
    name = name_list.pop()
    name, gender = " ".join(name[:2]), name[2].strip()

    cpr = rand_cpr(gender)
    while cpr in used_cprs:
        cpr = rand_cpr(gender)
    used_cprs.append(cpr)

    hos_id = random.choice(hospitals)[0]
    blood_type = random.choice(bloodtypes)

    patient_address = adresses.pop()

    row = [cpr, name, hos_id, blood_type, patient_address]
    patient_list.append(row)

list_to_SQL_list(patient_list, patient_file, "Patient")

## Populate Staff
n = 15
staff_file = "staff_pop.txt"
staff_list = []
staff_adresses = "unknown"
positions = ["Doctor", "Nurse"]
for _ in range(n):
    name = name_list.pop()
    name, gender = " ".join(name[:2]), name[2].strip()

    cpr = rand_cpr(gender, end_date = datetime.date(1995, 1, 1))
    while cpr in used_cprs:
        cpr = rand_cpr(gender)
    used_cprs.append(cpr)

    position = random.choice(positions)

    hiring_date = rand_date(datetime.date(int("19" + cpr[4:6]) + 24, 1, 1), datetime.date(2020, 1, 1))

    hos_id = random.choice(hospitals)[0]

    row = [cpr, name, position, hiring_date, hos_id]
    staff_list.append(row)

list_to_SQL_list(staff_list, staff_file, "Staff")

## Populate Donation
n = 20
donation_file = "donos_pop.txt"
dono_list = []
used_dono_ids = []

for _ in range(n):
    # choose a donor
    donor = random.choice(donor_list)
    donor_cpr = donor[0]
    hos_id = donor[2]

    # generate donation date
    start_date = datetime.date(2021, 1, 1)
    end_date = datetime.date(2021, 4, 1)
    dono_date = rand_date(start_date, end_date).strftime("%d/%m/%Y")

    # generate donationID
    dono_id = "{}_{}_{:03d}".format(hos_id, dono_date[0:2]+dono_date[3:5]+dono_date[6:10], random.randint(1,999))
    while dono_id in used_dono_ids:
        dono_id = "{}_{}_{:03d}".format(hos_id, dono_date[0:2]+dono_date[3:5]+dono_date[6:10], random.randint(1,999))
    used_dono_ids.append(dono_id)

    amount = "500 ml"

    # Perform medical check
    fail_chance = random.random()
    if fail_chance <= 0.05:
        medical_check = "Failed"
    else:
        medical_check = "Pass"

    row = [dono_id, donor_cpr, hos_id, amount, dono_date, medical_check]
    dono_list.append(row)

list_to_SQL_list(dono_list, donation_file, "Donations")
