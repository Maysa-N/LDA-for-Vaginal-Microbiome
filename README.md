# README.md
The Latent Dirichlet Allocation (LDA) model, adopted from the field of natural language processing, was used to uncover latent structure in the microbial community (Sankaran & Holmes, 2019). The analogy between the text and the microbiome-specific terms is: (document = sample); (word = sequencing read); (term = taxa); (topic = subcommunity).
Without prior normalisation, topic models were fitted to the count data of the ASVs using the topicmodels package in R. Unlike the Dirichlet-multinomial mixture method, LDA requires determining the number of topics (K) which can be estimated using the FindTopicsNumber function from the Idatuning package.
This repository contains the code for my analysis of the vaginal microbiome and reproductive success in sows.

## Files

- `vaginal_microbiome.R`: R script for data analysis
- `data/`: Directory containing raw data files (coming soon)
- `results/`: Directory containing analysis results (coming soon)

## How to Run the Analysis

1. Clone the repository:

   ```sh
   git clone https://github.com/Maysa-N/LDA-for-Vaginal-Microbiome.git
   cd LDA-for-Vaginal-Microbiome
