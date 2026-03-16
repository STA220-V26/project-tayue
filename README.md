i have started to create the folder structure and have read in the data. The data is stored under gitignore so that no sensitive data will be pushed to github (to practice). I started to build a pipeline to read in and unzip the data using tar_targets (define a step in the pipeline). The data that has been read in are in the targets.R file-Tova. 
I have started with the data linking process to be able to answear the question of how much a certain condition has in medication coast. I started to create new data frames that only has the columns of interest. after that i renamed the start and stop variables for condition and for medcation so that they can be seperated. i did also make choore that the format of the dates actually was numeric. Then i filtered only on the condition code present in both medication and condition file to be able to only get the results from a certain condition. i did also join patients "id" from patients file and "patients" from condition file. Then i created a new merged file and placed it in gitignore. -Tova 
i have started to work with the data and try to analyse the data: i have some suggestion which is the following: #What is the average medication cost for all individuals with the diagnostis
#Does the medication coast differ for the genders?
#what is the distribution of healthcare expenses across income?
#What is the average base cost for patients with this diagnosis?
#Regression analysis-->wheter income significantly predicts healtcare expenses 
i have worked on the script named Tova.R were you can find some overwiev of the data and the questions. 
i have viewed the data, i have done some summary statistics and started with a regression analysis as well. 
