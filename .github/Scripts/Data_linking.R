

#QUESTION: What does the medication cost for different conditions?
#Especially focusing on the condition: Acute bronchitis and its medication coast
#we can ofcourse try multiple this is just for start

#reason_code: 10509002
#condition: Acute bronchitis (disorder)

#Data linking to be able to answear the question:

#What we know:
#1--> condition start date for each patient
#2-->Medication for that condition must lie within the start date and the end date of the condition
#3 --> we must know that the medication given is actually linked to that condition 
#(becuase patients can get multiple conditions and treatments at the same time)
#4 medication are linked to cost 
# a patient can get muliple medications for a condition 

#Read in the essential files that we need to our question 
#fread for faster file reading
library(data.table)
library(dplyr)
library(tidyr)

#read in the data 
pat_data <- fread("data/data-fixed/patients.csv")
con_data <- fread("data/data-fixed/conditions.csv")
med_data <- fread("data/data-fixed/medications.csv")

head(pat_data) # 'id', 'gender', 'healthcare_expenses', 'healthcare_coverage', 'income'
head(con_data) # 'start', 'stop', 'patient', 'code', 'description'
head(med_data) # 'reasoncode', 'start', 'stop', 'patient', 'description', 'base_cost', 'payer_coverage', 'dispenses', 'totalcost', 'reasondescription'

#keep only the columns that we want to analyze 
patient <- pat_data |>
  select(id, gender, healthcare_expenses, healthcare_coverage, income) |>
  drop_na()

conditions <- con_data |>
  select(start, stop, patient, code, description) |>
  drop_na()

medications <- med_data |>
  select(reasoncode, start, stop, patient, description, base_cost, payer_coverage, dispenses, totalcost, reasondescription) |>
  drop_na()


head(patient)
head(conditions) 
head(medications)

#rename to clarify the names --> both conditions and medications has a column of start and stop --> will be mixed otherwise! 
conditions <- conditions |> rename(start_con= start)
conditions <- conditions |> rename(stop_con= stop)
conditions <- conditions |> rename(description_con= description)

medications <- medications |> rename(start_med = start)
medications <- medications |> rename(stop_med= stop)
medications <- medications |> rename(description_med= description)

head(patient)
head(conditions) 
head(medications)

#make choore the format is correct for the dates 
conditions$start_con <- as.Date(conditions$start_con)
conditions$stop_con <- as.Date(conditions$stop_con)
medications$start_med <- as.Date(medications$start_med)
medications$stop_med <- as.Date(medications$stop_med)


#only filter on a certain condition--> to look at the expenses of only that condition 
conditions <- conditions |>
  filter(code == 10509002)

medications <- medications |>
  filter(reasoncode == 10509002)

#Join patients id from patients file and patients from condition file 
patient_conditions <- conditions |>
  left_join(patient, by = c("patient" = "id"))

head(patient_conditions)

#create a merged data frame 
data_linked <- patient_conditions |>
  inner_join(medications, by = "patient") |>
  filter(
    code == reasoncode,
    start_med == start_con,
    stop_med == stop_con
  )

head(data_linked)

#to that the file is not tracked by git, so that the file is in gitignore. 
fwrite(data_linked, "data/data_linked.csv")


