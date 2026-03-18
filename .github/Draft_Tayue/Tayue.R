
# Q2: Does the medication coast differ for the genders?
library(data.table)
library(dplyr)

analysis_data <- fread("data_linked.csv")
head(analysis_data)
str(analysis_data)

analysis_data <- analysis_data |>
  mutate(
    income_quintile = factor(
      ntile(income, 5),
      levels = 1:5,
      labels = c("Lowest", "Low-Middle", "Middle", "High-Middle", "Highest")
    )
  )
analysis_data <- analysis_data |>
  group_by(patient, gender, age, income_quintile) |>
  summarise(
    total_medical_cost = sum(totalcost, na.rm = TRUE),
    base_cost = sum(base_cost, na.rm = TRUE),
    payer_coverage = sum(payer_coverage, na.rm =TRUE),
    n_encounters = n(),
    .groups = "drop"
  )

med_cost_summary <- analysis_data |>
group_by(gender) |>
summarise(
avg_med_cost = mean(totalcost, na.rm = TRUE),
median_med_cost = median(totalcost, na.rm = TRUE),
n_patients = n()
)

print(med_cost_summary)

# --- Statistical test: compare medication cost by gender ---
med_cost_ttest <- t.test(medication_cost ~ gender, data = analysis_data)
print(med_cost_ttest)

# --- Regression: medication cost as outcome ---
med_cost_model <- glm(
medication_cost ~ GENDER + AGE + PAYER,
family = Gamma(link = "log"),
data = analysis_data
)

summary(med_cost_model)
