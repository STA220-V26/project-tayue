#SUGGESTION for analysis 
#Just looking over the data_linked 

#what i am looking at:

#What is the average medication cost for all individuals with the condition?- Tova 
#Does the medication coast differ for the genders?
#what is the distribution of healthcare expenses across income?-Tova 
#What is the average base cost for individuals with this condition?

head(data_linked)
#For the condition of Acute bronchitis 

#total coast for the Acute bronchitis
sum(data_linked$totalcost)

mean(data_linked$totalcost) 


#Question--> how much does the total medication cost differ between genders?

#How many males and females do we have?
sum(data_linked$gender=="F") #5993
sum(data_linked$gender=="M") #6013
#Difference of 20 individuals 

#Visualize 
barplot(table(data_linked$gender))
#pretty equal dist between males and females 


#compare exakt the total coast for males and females 
sum(data_linked$totalcost[data_linked$gender=="F"]) 
sum(data_linked$totalcost[data_linked$gender=="M"]) 
#Difference in total coast = 13 773

#what is the average total medication coast for each gender?
tapply(data_linked$totalcost, data_linked$gender, mean)

#visual sense of coast difference 
boxplot(totalcost ~ gender, data = data_linked )


#Question-->what is the distribution of healthcare expenses across income?

#Does cost increase with income?
plot(data_linked$income, data_linked$healthcare_expenses, 
xlab= "Income",
ylab="Healtcare Expenses ",
main= "healtcare Expenses vs income")

#Hevenly tailed data--> Right skewed dist 
hist(data_linked$income)
hist(data_linked$healthcare_expenses)

#summary 
summary(data_linked$healthcare_expenses)
summary(data_linked$income)

#what is the average income by gender?
tapply(data_linked$income, data_linked$gender, mean)


#Regression --> wheter income significantly predicts healtcare expenses 
#log becuase of the right tailed data for both of the variables 
model <- lm(log(healthcare_expenses) ~ log(income) , data =data_linked)

 #Assumption 
plot(model, which = 1) #residual vs fitted 
plot(model, which = 2) #normality
plot(model, which = 3) #homoscedasity

#Normallity seems good
#Linearity assumption not good at all 
#Heteroscedacity problem 

#maybe due to outliers?
boxplot(data_linked$healthcare_expenses)
#YES we have a lot of ouliers seems like they may have a strong influence on the regression 
#people with this condition (Acute bronchitis) seem to have very high healt care expenses for this condition 


#Do income and healthcare expenses significantly predict total disease cost?
model1<-glm(log(totalcost) ~ log(income) + log(healthcare_expenses) , data =data_linked)

plot(model1, which = 1) #residual vs fitted 
plot(model1, which = 2) #normality
plot(model1, which = 3) #homoscedasity

summary(model1)

model2<-lm(log(totalcost) ~ log(income) + log(healthcare_expenses) + gender + base_cost + payer_coverage + healthcare_coverage , data =data_linked)
summary(model2)


#Question-->What is the average base cost for patients with this diagnosis?

mean(data_linked$base_cost)
summary(data_linked$base_cost)

#Average base cost by gender 
tapply(data_linked$base_cost, data_linked$gender, mean)





