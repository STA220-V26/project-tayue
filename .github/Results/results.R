
#Plots for the result 

#plot for total coast differences between the genders 
plot1 <- ggplot(data_linked, aes(x = gender, y = totalcost)) +
  geom_boxplot()
plot1

dir.create("Results", showWarnings = FALSE)
ggsave("Results/gender_boxplot.png", plot = plot1, width = 8, height = 6)

#total average cost for the condition plot 
library(knitr)
summary_table_totalcost <- data_linked |>
  summarise(
    sum_total_cost = sum(totalcost, na.rm = TRUE),
    average_total_cost = mean(totalcost, na.rm = TRUE)
  )

kable(summary_table_totalcost, caption = "Summary of total medication cost")

#income vs healtcare expenses 
ggplot(data_linked, ases=income, y=healthcare_expenses) + 
    geom_point() + 
    labs(
        x="Income",
        y= "Healtcare expenses",
        title = "Healtcare expenses vs income "
    )

## Distribution of total medication cost


ggplot(data_linked, aes(X=totalcost)) + 
    geom_histogram(bins=30) +
    labs(
        title= "Distribution of Total medication cost for Acute bronchitis",
        x="Total Medication cost",
        y="counts",
    ) + 
        theme_minimal

   
## Distribution of income

ggplot(data_linked, aes(X=income)) + 
    geom_histogram(bins=30) +
    labs(
        title= "Distribution of income",
        x="income",
        y="counts",
    ) + 
        theme_minimal

ggplot(data_linked, aes(y=healtcare_expenses)) +
    geom_boxplot() +
    labs(
    y="Boxplot of Healtcare expenses") +
        theme_minimal()

 ggplot(data_linked, aes(y=income)) +
    geom_boxplot() +
    labs(
    y="Boxplot of income") +
        theme_minimal()