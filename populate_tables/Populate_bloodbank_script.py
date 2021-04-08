#!/usr/bin/env python3
# Author: Mathias Rahbek-Borre (s183447)
# Date: 31-3-2021
# Course: Database systems
import random
import datetime
import re


def rand_date(start_date, end_date):
    """ Outputs a random date between two dates.
    """
    time_between_dates = end_date - start_date
    days_between_dates = time_between_dates.days
    random_number_of_days = random.randrange(days_between_dates)
    random_date = start_date + datetime.timedelta(days=random_number_of_days)
    return random_date


def rand_cpr(gender, start_date = datetime.date(1950, 1, 1), end_date = datetime.date(2002, 1, 1)):
    """ Generates a random CPR-number for a specific gender with a birthday
        between two dates.
    """
    new_date = rand_date(start_date, end_date).strftime("%d%m%y")

    last_cpr_num = random.randrange(1000, 9999, 2)

    if gender == "Male":
        last_cpr_num += 1

    return "{}-{}".format(new_date, last_cpr_num)


def list_to_SQL_list(list, outfilename, SQL_table_name):
    """ Function that takes a list of lists, a file name and a table name,
        creates a SQL format insert statement and writes it to the file.
    """
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

    return None


random.seed(3)

# Number of row for each table(always 3 hospitals):
n_donors = 30
n_donations = 45
n_patients = 20
n_staff = 15

## Populate Hospital
hospitals = [["RIG", "Rigshospitalet", "Blegdamsvej 9, 2100 København"],
            ["OUH", "Odense University Hospital", "J. B. Winsløws Vej 4, 5000 Odense"],
            ["AUH", "Aarhus University Hospital", "Palle Juul-Jensens Blvd. 99, 8200 Aarhus"]]

hospital_file = "hospital_pop.txt"

names = open("random_names_w_gender.csv", "r")
name_list = [re.sub('\"',"",line).split(",") for line in names]
names.close()

bloodtypes = ["O-","O+","A-","A+","B-","B+","AB-","AB+"]

## Populate Donor
donor_file = "donor_pop.txt"
donor_list = []
used_cprs = []
for _ in range(n_donors):
    name = name_list.pop()
    name, gender = " ".join(name[:2]), name[2].strip()

    cpr = rand_cpr(gender)
    while cpr in used_cprs:
        cpr = rand_cpr(gender)
    used_cprs.append(cpr)

    hos_id = random.choice(hospitals)[0]
    blood_type = random.choice(bloodtypes)

    last_donation = "NULL"

    row = [cpr, name, hos_id, blood_type, last_donation]
    donor_list.append(row)

## Populate Patient
patient_file = "patient_pop.txt"
patient_list = []

infile = open("adresses_short.txt","r")
adresses = []
for line in infile:
    if line.strip() not in adresses:
        adresses.append(line.strip())
infile.close

for _ in range(n_patients):
    name = name_list.pop()
    name, gender = " ".join(name[:2]), name[2].strip()

    cpr = rand_cpr(gender)
    while cpr in used_cprs:
        cpr = rand_cpr(gender)
    used_cprs.append(cpr)

    hos_id = random.choice(hospitals)[0]
    blood_type = random.choice(bloodtypes)

    patient_address = adresses.pop()

    row = [cpr, name, patient_address, blood_type, hos_id]
    patient_list.append(row)

list_to_SQL_list(patient_list, patient_file, "Patient")

## Populate Staff
# initialize variables
staff_file = "staff_pop.txt"
staff_list = []
positions = ["Doctor", "Nurse"]

# create n random staff members
for _ in range(n_staff):
    # Get new name from list
    name = name_list.pop()
    name, gender = " ".join(name[:2]), name[2].strip()

    # Generate random CPR-number and ensure that it is unique
    cpr = rand_cpr(gender, end_date = datetime.date(1995, 1, 1))
    while cpr in used_cprs:
        cpr = rand_cpr(gender)
    used_cprs.append(cpr)

    # Assign random position
    position = random.choice(positions)

    # Assign random hiring date between 24 years after their birthday and 2020
    hiring_date = rand_date(datetime.date(int("19" + cpr[4:6]) + 24, 1, 1), datetime.date(2020, 1, 1))

    # Assign to random hospital
    hos_id = random.choice(hospitals)[0]

    # Create row and insert into the table as list of lists
    row = [cpr, name, position, hiring_date, hos_id]
    staff_list.append(row)

## Populate Donation
donation_file = "donos_pop.txt"
dono_list = []
used_dono_ids = []

for _ in range(n_donations):
    # choose a donor
    donor = random.choice(donor_list)
    donor_cpr = donor[0]
    hos_id = donor[2]

    # generate donation date
    start_date = datetime.date(2021, 1, 1)
    end_date = datetime.date(2021, 4, 1)
    dono_date = rand_date(start_date, end_date)
    dono_date_str = dono_date.strftime("%d/%m/%Y")

    # generate donationID
    dono_id = "{}_{}_{:03d}".format(hos_id, dono_date_str[0:2]+dono_date_str[3:5]+dono_date_str[6:10], random.randint(1,999))
    while dono_id in used_dono_ids:
        dono_id = "{}_{}_{:03d}".format(hos_id, dono_date_str[0:2]+dono_date_str[3:5]+dono_date_str[6:10], random.randint(1,999))
    used_dono_ids.append(dono_id)

    dono_staff = random.choice(staff_list)
    # ensure hos_id matches patient
    while dono_staff[4] != hos_id:
        dono_staff = random.choice(staff_list)
    dono_staff_id = dono_staff[0]

    amount = 500

    # Perform medical check
    fail_chance = random.random()
    if fail_chance <= 0.05:
        medical_check = "Failed"
    else:
        medical_check = "Pass"

    been_used = "Unused"

    row = [dono_id, donor_cpr, hos_id, dono_staff_id, amount, dono_date, medical_check, been_used]
    dono_list.append(row)


## Populate MedicalRecords
used_case_numbers = []
diseases = ["Infection", "Cancer", "Anemia", "Acute blood loss"]
status_options = ["Acute", "Stable", "Released"]

med_record_file = "med_record_pop.txt"
assignment_file = "assignment_pop.txt"
blood_trans_file = "blood_trans_pop.txt"

med_records = []
assignment = []
bloodtransfusions = []

blood_type_recieve_dict =  {"O-": set(("O-")),
                            "O+": set(("O-", "O+")),
                            "B-": set(("O-", "B-")),
                            "B+": set(("O-", "O+", "B-", "B+")),
                            "A-": set(("O-","A-")),
                            "A+": set(("O-", "O+", "A-", "A+")),
                            "AB-": set(("O-", "B-", "A-", "AB-")),
                            "AB+": set(("O-", "O+", "B-", "B+", "A-", "A+", "AB-", "AB+"))
                            }

for patient in patient_list:

    patient_id = patient[0]

    case_number = random.randrange(10000000, 99999999)
    while case_number in used_case_numbers:
        case_number = random.randrange(10000000, 99999999)
    used_case_numbers.append(case_number)

    diagnosis = random.choice(diseases)

    status = random.choice(status_options)

    med_records.append([patient_id, case_number, diagnosis, status])

    ## populate assignments
    if random.random() < 0.3:
        n_assigned = 2
    else:
        n_assigned = 1

    assigned_staff = []
    for _ in range(n_assigned):
        ass_staff = random.choice(staff_list)
        # ensure hos_id matches patient
        while ass_staff[4] != patient[2] and ass_staff[0] in assigned_staff:
            ass_staff = random.choice(staff_list)
        assigned_staff.append(ass_staff[0])



        # generate assignment date
        start_date = datetime.date(2021, 1, 1)
        end_date = datetime.date(2021, 4, 1)
        ass_date = rand_date(start_date, end_date)

        assignment.append([ass_staff[0], case_number, ass_date])

    # populate
    if (diagnosis == "Anemia" or diagnosis == "Acute blood loss") and status != "Acute":
        print("looking for transfusion")
        for dono in dono_list:

            if dono[6] == "Failed":
                continue

            if dono[-1] == "Used":
                continue

            blood_match = False
            for donor in donor_list:
                if donor[0] == dono[1] and donor[3] in blood_type_recieve_dict[patient[3]]:
                    blood_match = True
                    break

            if blood_match == False:
                continue

            trans_dono_id = dono[0]

            dono_date = dono[5]
            dono_exp_date = dono_date + datetime.timedelta(days=42)

            if dono_exp_date < ass_date:
                continue
            else:
                trans_date = rand_date(max(dono_date, ass_date), min(dono_exp_date, datetime.date(2021, 4, 1)))

                amount = 500

                bloodtransfusions.append([trans_dono_id, case_number, trans_date, amount])

                for i, dono in enumerate(dono_list):
                    if dono[0] == trans_dono_id:
                        dono_list[i][-1] = "Used"
                        break
            break
        else:
            print("no trans found")

list_to_SQL_list(hospitals, hospital_file, "Hospital")
list_to_SQL_list(donor_list, donor_file, "Donor")
list_to_SQL_list(patient_list, patient_file, "Patient")
list_to_SQL_list(staff_list, staff_file, "Staff")
list_to_SQL_list(dono_list, donation_file, "Donations")
list_to_SQL_list(med_records, med_record_file, "MedicalRecord")
list_to_SQL_list(assignment, assignment_file, "Assignment")
list_to_SQL_list(bloodtransfusions, blood_trans_file, "BloodTransfusions")
