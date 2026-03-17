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
tar_target(encounters, data.table::fread("data/encounters.csv")),
tar_target(conditions, data.table::fread("data/conditions.csv")),
tar_target(patients, data.table::fread("data/patients.csv")),
tar_target(payer_transitions, data.table::fread("data/payer_transitions.csv")),

# Identify acute bronchitis cases
tar_target(
  bronchitis,
  conditions |>
    dplyr::filter(
      stringr::str_detect(
        tolower(DESCRIPTION),
        "acute bronchitis"
      )
    )
),

# Link bronchitis to encounters
tar_target(
  bronchitis_encounters,
  bronchitis |>
    dplyr::select(PATIENT, ENCOUNTER) |>
    dplyr::inner_join(encounters, by = c("PATIENT", "ENCOUNTER"))
),

# Compute encounter-level costs (USE TOTAL_CLAIM_COST)
tar_target(
  bronchitis_costs,
  bronchitis_encounters |>
    dplyr::mutate(
      total_cost = TOTAL_CLAIM_COST
    )
),

# Aggregate to patient-level total medical cost
tar_target(
  patient_costs,
  bronchitis_costs |>
    dplyr::group_by(PATIENT) |>
    dplyr::summarise(
      total_medical_cost = sum(total_cost, na.rm = TRUE),
      n_encounters = dplyr::n()
    )
),

# Extract payer (coverage)
tar_target(
  coverage,
  payer_transitions |>
    dplyr::group_by(PATIENT) |>
    dplyr::summarise(
      PAYER = dplyr::first(PAYER)
    )
),

# Final analytic dataset
tar_target(
  analysis_data,
  patient_costs |>
    dplyr::left_join(patients, by = "PATIENT") |>
    dplyr::left_join(coverage, by = "PATIENT")
),

# Cost model (Gamma regression)
tar_target(
  cost_model,
  glm(
    total_medical_cost ~ AGE + GENDER + PAYER,
    family = Gamma(link = "log"),
    data = analysis_data
  )
)

)
