
# Q2: Does the medication coast differ for the genders?
library(data.table)
library(dplyr)

# Load and Clean
analysis_data <- fread("data/data_linked.csv")

# Creating income quintile
analysis_data <- analysis_data |>
  mutate(
    income_quintile = factor(
      ntile(income, 5),
      levels = 1:5,
      labels = c("Lowest", "Low-Middle", "Middle", "High-Middle", "Highest")
    )
  )

# Aggregate to Patient Level
analysis_data <- analysis_data |>
  group_by(patient, gender, income_quintile) |>
  summarise(
    total_medical_cost = sum(totalcost, na.rm = TRUE),
    base_cost = sum(base_cost, na.rm = TRUE),
    payer_coverage = sum(payer_coverage, na.rm = TRUE),
    n_encounters = n(),
    .groups = "drop"
  )

# Descriptive Summary Table
med_cost_summary <- analysis_data |>
  group_by(gender) |>
  summarise(
    avg_med_cost = mean(total_medical_cost, na.rm = TRUE),
    median_med_cost = median(total_medical_cost, na.rm = TRUE),
    n_patients = n()
  )

print(med_cost_summary)

# Statistical test: compare medication cost by gender ---
med_cost_ttest <- t.test(total_medical_cost ~ gender, data = analysis_data)
print(med_cost_ttest)

#  Regression: medication cost as outcome ---
med_cost_model <- glm(
  total_medical_cost ~ gender + income_quintile, 
  family = Gamma(link = "log"), 
  data = analysis_data |> filter(total_medical_cost > 0)
)

summary(med_cost_model)


# Q4 
