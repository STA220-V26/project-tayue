#SET-UP to download the data we want to use and to place the data in git-ignore 

library(targets)

tar_option_set(
  packages = c(
    "targets",
    "tidyverse",
    "data.table",
    "pointblank",
    "qs2",
    "janitor",
    "readr",
    "fs",
    "curl",
    "stringr",
    "lubridate"
  )
)

list(

# Create data directory
tar_target(
  create_data_dir,
  fs::dir_create("data"),
  cue = tar_cue(mode = "always")
),

# Download dataset
tar_target(
  zip_file,
  {
    if (!fs::file_exists("data/data.zip")) {
      message("Downloading data.zip from GitHub")
      curl::curl_download(
        "https://github.com/STA220/cs/raw/refs/heads/main/data.zip",
        "data/data.zip"
      )
    }
    "data/data.zip"
  },
  format = "file"
),

# Unzip dataset
tar_target(
  extracted_files,
  zip::unzip(zip_file, exdir = "data"),
  format = "file"
),

# Load datasets
tar_target(patients, data.table::fread("data/patients.csv")),
tar_target(encounters, data.table::fread("data/encounters.csv")),
tar_target(procedures, data.table::fread("data/procedures.csv")),
tar_target(careplans, data.table::fread("data/careplans.csv")),
tar_target(conditions, data.table::fread("data/conditions.csv")),
tar_target(payer_transitions, data.table::fread("data/payer_transitions.csv")),

# Healthcare utilization measures
tar_target(
  utilization,
  encounters |>
    dplyr::group_by(PATIENT) |>
    dplyr::summarise(
      total_visits = dplyr::n(),
      emergency_visits = sum(ENCOUNTERCLASS == "emergency", na.rm = TRUE),
      inpatient_visits = sum(ENCOUNTERCLASS == "inpatient", na.rm = TRUE)
    )
),

tar_target(
  procedure_use,
  procedures |>
    dplyr::group_by(PATIENT) |>
    dplyr::summarise(
      procedures_count = dplyr::n()
    )
),

tar_target(
  careplan_use,
  careplans |>
    dplyr::group_by(PATIENT) |>
    dplyr::summarise(
      careplans_count = dplyr::n()
    )
),

tar_target(
  health_status,
  conditions |>
    dplyr::group_by(PATIENT) |>
    dplyr::summarise(
      conditions_count = dplyr::n()
    )
),

# Insurance coverage
tar_target(
  coverage,
  payer_transitions |>
    dplyr::group_by(PATIENT) |>
    dplyr::summarise(
      payer = dplyr::first(PAYER)
    )
),

# Build final analysis dataset
tar_target(
  analysis_data,
  patients |>
    dplyr::left_join(utilization, by = "PATIENT") |>
    dplyr::left_join(procedure_use, by = "PATIENT") |>
    dplyr::left_join(careplan_use, by = "PATIENT") |>
    dplyr::left_join(health_status, by = "PATIENT") |>
    dplyr::left_join(coverage, by = "PATIENT")
),

# Clean patient dataset
tar_target(
  patients_clean,
  analysis_data |>
    janitor::remove_empty() |>
    janitor::remove_constant()
),

# Validation report
tar_target(
  validation_report,
  {
    checks <-
      patients_clean |>
      pointblank::create_agent(label = "Patient validation") |>
      pointblank::col_vals_between(
        vars(BIRTHDATE),
        as.Date("1900-01-01"),
        Sys.Date(),
        na_pass = TRUE
      ) |>
      pointblank::interrogate()

    pointblank::export_report(
      checks,
      "patient_validation.html"
    )

    "patient_validation.html"
  },
  format = "file"
),

# Regression model: effect of coverage on utilization
tar_target(
  utilization_model,
  lm(
    total_visits ~ payer + AGE + GENDER + conditions_count,
    data = patients_clean
  )
)

)