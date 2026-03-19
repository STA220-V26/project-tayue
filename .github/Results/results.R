
#in this document i have made some more nice formats for the plots that i use in the Quatro representation, all based on our anlysis scripts. 


#Plots for the result 
dir.create("Results", showWarnings = FALSE)

#plot for total coast differences between the genders 
plot1 <- ggplot(data_linked, aes(x = gender, y = totalcost)) +
  geom_boxplot()
plot1


ggsave("Results/gender_boxplot.png", plot = plot1, width = 8, height = 6)

med_cost_summary <- analysis_data |>
  group_by(gender) |>
  summarise(
    avg_med_cost = mean(total_medical_cost, na.rm = TRUE),
    median_med_cost = median(total_medical_cost, na.rm = TRUE),
    n_patients = n(),
    .groups = "drop"
  )

med_cost_summary |>
  mutate(
    avg_med_cost = round(avg_med_cost, 2),
    median_med_cost = round(median_med_cost, 2)
  ) |>
  knitr::kable(
    col.names = c("Gender", "Average medical cost", "Median medical cost", "Number of patients"),
    caption = "Summary of total medical cost by gender"
  )

#Nice format for the summary model of the regression about gender and the income quantiles on the total cost. 
model_sum <- summary(med_cost_model)
model_summary_table <- data.frame(
  Term= rownames(model_sum$coefficients), 
  Estimate= model_sum$coefficients[,1], 
  Std_Error = model_sum$coefficients[,2],
  z_value = model_sum$coefficients[,3],
  p_value=model_sum$coefficients[,4]
)

model_summary_table$Estimate <- round(model_summary_table$Estimate, 3)
model_summary_table$Std_Error <- round(model_summary_table$Std_Error, 3)
model_summary_table$z_value <- round(model_summary_table$z_value, 3)
model_summary_table$p_value <- round(model_summary_table$p_value, 4)

knitr::kable(
  model_summary_table,
  col.names = c("Name", "Estimate", "Std. Error", "z value", "p-value"),
  caption = "Regression model for the effect of gender and income on total cost"
)


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


#results from the qmd to the html 
quarto::quarto_render("analysis.qmd")
