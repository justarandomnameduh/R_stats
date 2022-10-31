# Load data from csv file

raw_data <- read.csv("house_price.csv")
data <- data[,c('price', 'sqft_living', 'floors', 'condition',
                'sqft_above', 'sqft_living15')]

# Get correlation between each feature
corr_df <- as.data.frame(cor(data, use='complete.obs'))
col_list <- list()
for(col in colnames(corr_df)){
  col_list <- append(col_list,paste("corr_", col))
}
colnames(corr_df) <- col_list

# Calculate mean and variance of each feature
mv_df <- data.frame(feature=character(),
                    mean=double(),
                    variance=double())
for (col in colnames(data)){
  mv_df[nrow(mv_df) + 1,] <- c(col, mean(data[,col], na.rm=TRUE), var(data[,col], na.rm=TRUE))
}
rownames(mv_df) <- mv_df$feature
mv_df <- mv_df[,c('mean', 'variance')]

# Merge 2 df above into 1
stat_df <- merge(corr_df, mv_df, by=0, all.x=TRUE)

# Graphing
png("my_plot.png", width = 650, height = 500)
par(mfrow=c(2,3))

for (col in colnames(data)) {
  hist(data[,col], labels=data[,col], xlab = col, main=col, breaks=35)
}
dev.off()
