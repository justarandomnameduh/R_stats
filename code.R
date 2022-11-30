library(ggcorrplot)
library(corrr)
library(data.table)
library(lmtest)
library(MASS)
library(vip)
library(car)
library(tidyr)
library(dplyr)
library(corrplot)
library(RColorBrewer)
library(summarytools)
library(tidyverse)
library(caret)

### Data preprocessing
housePriceData <- read.csv("house_price.csv")
housePrice <- housePriceData[,c('price', 'sqft_living', 'floors',
                                'condition','sqft_above', 'sqft_living15')]

options(max.print = 50)
housePrice

# Check for NaN values
sum(is.na(housePrice))

# There are NaN values in the data
# As the number of observations is large enough,
# We decide to remove datapoints with NaN values
housePrice <- housePrice %>% drop_na()

# Check for duplication
duplicated(housePrice) %>% sum()

# There are duplication so we remove it from the dataframe
housePrice <- distinct(housePrice)

### Descriptive statistic:
CR <- cor(housePrice)
View(CR)
png("corr_plot.png", width = 650, height = 650)

corrplot(CR, type = "full", order="hclust",
         col = brewer.pal(n=3,name="RdYlBu"),
         main = "\nCorrelation Heatmap")
dev.off()

descr(as.data.frame(housePrice), transpose = TRUE,
      stats = c('mean', 'sd', 'min', 'max', 'med',
                'Q1', 'IQR', 'Q3'))

### Visualization
# Histogram
png("hist_plot.png", width = 1300, height = 1000)
par(mfrow=c(2,3))

for (col in colnames(housePrice)) {
  hist(housePrice[,col], labels=housePrice[,col], xlab = col, main=col, breaks=35,
       cex.lab=2, cex.axis=2, cex.main=3, cex.sub=2)
}
dev.off()

# Boxplot
png("box_plot.png", width = 1300, height = 1000)
par(mfrow=c(2,3))

for (col in colnames(housePrice)) {
  boxplot(housePrice[,col], labels=housePrice[,col], xlab = col, main=col, breaks=35, 
          cex.lab=2, cex.axis=2, cex.main=3, cex.sub=2)
}
dev.off()

# Pairs plot
png("pairs_plot.png", width = 4000, height = 4000)

pairs(housePrice, cex.labels=7, pch=19, cex = 4, cex.axis = 5)
dev.off()

### Linear Regression
# Split data into train and test set
set.seed(1)

random_sample <- createDataPartition(housePrice$price, p=0.8, list=FALSE)
train_data <- housePrice[random_sample,]
test_data <- housePrice[-random_sample,]

# Create a standard linear regression model
linreg <- lm(price ~., data = train_data)
predictions <- predict(linreg, test_data)
error_df <- data.frame( R2 = R2(predictions, test_data$price),
                        RMSE = RMSE(predictions, test_data$price),
                        MAE = MAE(predictions, test_data$price))
coef_list <- data.frame(linreg$coefficients)
summary(linreg)
write.csv(coef_list, "linreg_coef.csv", row.names=TRUE)
write.csv(error_df, "linreg_error.csv", row.names=TRUE)