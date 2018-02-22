# Consumer lifestyle segmentation

This project was built in R language for the data team at Moutain Equipment Coorporation. Sharing outputs have been de-identified to protect individual privacy.

### Repository's structure

```bash
.
├── misc
│   ├── helper_functions.R
│   ├── make_marginals.R
│   ├── make_tsne_plot.R
│   ├── my_sildist.R
│   └── rename_vars.R
├── output
│   ├── gower_dist.rds
│   ├── kmean_stability_assessment.txt
│   ├── sample_data.txt
│   └── summary.txt
├── README.md
├── settings.R
├── src
│   ├── build_lda_predictor.R
│   ├── clean_data.R
│   ├── create_models.R
│   ├── make_tab_2.R
│   ├── make_tab.R
│   └── make_weight.R
└── viz
    ├── kmean_silhouette_width_vs_num_clusters.png
    ├── kmean_tsne_2clusters.png
    ├── pam_silhouette_width_vs_num_clusters.png
    └── pam_tsne_5clusters.png
```

### Project goals: 
- Build consumer health lifestyle segmentation based on respondents' age, current health condition and the conditions they like to prevent in the future
- Identify clusters and intepret its meaning via descriptive statistics
- Provide titbits through profile questions on lifestyle and social demographics
- Future work: prototype a lifestyle scoring tool to predict a class / segment for a new consumer
