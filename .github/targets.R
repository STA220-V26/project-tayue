#SET-UP to download the data we want to use and to place the data in git-ignore 

 #Load essential librarys to be used
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
    "duckplyr",
    "decoder",
    "stringr",
    "lubridate",
    "usethis",
    "leaflet"
  )
)

list(

  tar_target(
    create_data_dir,
    fs::dir_create("data"),
    cue = tar_cue(mode = "always")
  ),

  tar_target(
    zip_file,
    {
      if (!fs::file_exists("data/data.zip")) {
        message("Downloading data.zip from GitHub")
        curl::curl_download(
          "https://github.com/STA220/cs/raw/refs/heads/main/data.zip",
          "data/data.zip",
          quiet = FALSE
        )
      }

      "data/data.zip"
    }
  ),
#No sensitive data to GitHub
tar_target(
gitignore_data,
usethis::use_git_ignore("data/")
)
#Unzipping the data using targets as used in the lectures
  tar_target(
    zipdata,
    "data/data.zip",
    format = "file"
  ),

  tar_target(
    extracted_files,
    zip::unzip(zipdata, exdir = "data"),
    format = "file"
  ),

  tar_target(
    csv_paths,
    extracted_files[stringr::str_detect(extracted_files, "\\.csv$")],
    format = "file"
  ),

  tar_target(
    Raw_data,
    readr::read_csv(
      unz(zip_file, "data-fixed/patients.csv")
    ) |>
      data.table::setDT() |>
      data.table::setkey(id)
  ),

  # Clean dataset
  tar_target(
    patients_clean,
    Raw_data |>
      janitor::remove_empty(quiet = FALSE) |>
      janitor::remove_constant(quiet = FALSE)
  ),

  # Validation report
  tar_target(
    validation_report,
    {
      checks <-
        patients_clean |>
        pointblank::create_agent(label = "Patient validation") |>
        pointblank::col_vals_between(
          where(is.Date),
          as.Date("1900-01-01"),
          Sys.Date(),
          na_pass = TRUE
        ) |>
        pointblank::col_vals_gte(
          deathdate,
          vars(birthdate),
          na_pass = TRUE
        ) |>
        pointblank::col_vals_regex(
          ssn,
          "[0-9]{3}-[0-9]{2}-[0-9]{4}$"
        ) |>
        pointblank::col_is_integer(id) |>
        pointblank::interrogate()

      pointblank::export_report(
        checks,
        "patient_validation.html"
      )

      "patient_validation.html"
    },
    format = "file"
  ),


