

##SET-UP to download the data we want to use and to place the data in git-ignore 

 #Load essential librarys to be used
library(janitor)
library(tidyverse)
library(data.table)
library(zip)
library(rvest)
library(fs)
library(targets)
library(tarchetypes)
library(labelled)

#No sensitive data to GitHub
usethis::use_git_ignore("data/")

#Create data folder to store the data
fs::dir_create("data")

#Download data into data map
if (!fs::file_exists("data/data.zip")) {
  message("Downloading data.zip from GitHub")
  curl::curl_download(
    "https://github.com/STA220/cs/raw/refs/heads/main/data.zip",
    "data/data.zip",
    quiet = FALSE
  )
}
#Unzipping the data using targets as used in the lectures
#tar target is to define a step in the pipeline

 list(tar_target(zipdata,"../data/data.zip", format = "file" #define a target to replace the zip file
  ),
 tar_target(csv_files, zip::unzip(zipdata, exdir = "../data"),format = "file" #unzipping the file 
  ),
 tar_target(csv_paths,list.files("../data", pattern = "\\.csv$", full.names = TRUE, recursive = TRUE),format = "file" #find all CSV files inside /data 
  ),
 tar_target(dt,data.table::fread(csv_paths),pattern = map(csv_paths) #read the CSV files each file is read in seperatley. 
  ) #we are creating one target per CSV 
)

zip_file <- "data/data.zip"
extract_to <- "data"
zip::unzip(zip_file, exdir = extract_to)

