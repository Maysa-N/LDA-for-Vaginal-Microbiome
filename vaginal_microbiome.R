# Loading the required packages"
library(alto)
library(dplyr)
library(magrittr)
library(ggplot2)
library(tibble)
library(stringr)
library(tidyr)

# Start with the phyloseq object
# building the list:
my_phyloseq <- physeq
taxonomy <- as.data.frame(tax_table(my_phyloseq))
otu_df <- as.data.frame(t(otu_table(my_phyloseq)))
sample_metadata_df <- as.data.frame(sample_data(my_phyloseq))

mydata <- list(
  counts = otu_df,
  taxonomy = taxonomy,
  sample_info = sample_metadata_df
)

# Clean & nice ASV names
# 
mydata$taxonomy <-
  mydata$taxonomy %>%
  as.data.frame() %>%
  group_by(Genus, Species) %>%
  mutate(
    ASV_name =
      paste0(
        ifelse(is.na(Genus),"[unknown Genus]", Genus), " (",
        ifelse(is.na(Species),"?", Species), ") ",
        row_number()
      )
  ) %>%
  ungroup()

mydata$taxonomy <-
  mydata$taxonomy %>%
  as.data.frame() %>%
  group_by(Genus) %>%
  mutate(
    ASV_name1 =
      paste0(
        ifelse(is.na(Genus),"[unknown Genus]", Genus), " (",
        row_number()
      )
  ) %>%
  ungroup()
# Assign colnames of the count matrix 
colnames(mydata$counts) <-  mydata$taxonomy$ASV_name1
# Remove rows with zero counts
non_zero_rows <- rowSums(mydata$counts) > 0
filtered_counts <- mydata$counts[non_zero_rows, ]

set.seed(71)
lda_varying_params_lists <-  list()
for (k in 1:7) {lda_varying_params_lists[[paste0("k",k)]] <- list(k = k)}

# Run LDA models with filtered data
lda_models <- run_lda_models(
  data = filtered_counts,
  lda_varying_params_lists = lda_varying_params_lists,
  lda_fixed_params_list = list(method = "VEM"),
  reset = FALSE,
  verbose = TRUE
)


#align the topics from each consecutive models:
aligned_topics_product <- 
  align_topics(
    models = lda_models,
    method = "product") 

#plot
plot(aligned_topics_product)

# get the available paths
compute_number_of_paths(aligned_topics_product) %>% 
  plot_number_of_paths() + 
  ggtitle("Method: product")

# plot with thw ASVs

aligned_topics_transport_7 <- align_topics(lda_models[1:7], method = "product")
plot(aligned_topics_transport_7, add_leaves = TRUE, label_topics = TRUE)

plot_beta(aligned_topics_product, models = c("k1", "k6","k7"), threshold = 0.005)


# Visualize the composition of each topic
# Top terms for each topic
top_terms <- b_df %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)



top_terms <- topic_term %>%
  group_by(topic) %>%
  top_n(20, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Plot the top terms for each topic
top_terms_plot <- ggplot(top_terms, aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_y") +
  coord_flip() +
  labs(title = "Top Terms for Each Topic",
       x = "Term",
       y = "Beta") +
  theme_minimal()

print(top_terms_plot)

# Composition of each topic in each document
document_topic <- g_df %>%
  group_by(document) %>%
  mutate(proportion = gamma / sum(gamma))

# Plot the topic proportions for each document
document_topic_plot <- ggplot(document_topic, aes(document, proportion, fill = factor(topic))) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Topic Proportions for Each Document",
       x = "Document",
       y = "Proportion",
       fill = "Topic") +
  theme_minimal()

print(document_topic_plot)

