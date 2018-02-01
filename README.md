# Consumer lifestyle segmentation

This project was built in R language for the data team at Moutain Equipment Coorporation. Sharing outputs have been deidentified for privacy protection. 

### Project structure

```bash
.
├── misc
│   ├── helper_functions.R
│   ├── make_marginals.R
│   └── rename_vars.R
├── output
│   ├── clusterboot.RData
│   ├── cluster_by_uuid.csv
│   ├── deidentified_train.rds
│   ├── demo_profiling_variables_by_cluster.xlsx
│   ├── gower_mat.RData
│   ├── results.xlsx
│   └── train.rds
├── README.md
├── settings.R
├── src
│   ├── clean_data.R
│   ├── create_models.R
│   ├── make_tab_2.R
│   ├── make_tab.R
│   └── make_weight.R
└── viz
    ├── distance_hist.png
    ├── silhouette_width_to_select_k.png
    ├── tsne_cluster_7.png
    ├── tsne_cluster.png
    └── viz.tar.gz
```


### Project goals: 
- To build a consumer health lifestyle segmentation based on their age, current health condition and the health conditions they want to prevent in the future
- Identify segments and intepret its meaning via descriptive statistics
- Provide titbits by profiling questions on lifestyle and social demogpraphics
- Future work: prototype a health lifestyle scoring tool to predict a class / segment for a new customer

### Methods
1. Inputs:
  1.1. A multiple-select question on health condition and prevention is converted to a set of binary variables. Each of binary variables represent one category in the question. The varible is coded 1 if the category is selected and 0 otherwise. 
  1.2. Age is dichotomized into two groups: less than 58 or 58 plus 

2. Analysis:
   2.1. Data quality checks: to remove the low-quality data, that is speeding through the survey by giving low-effort responses, engaging in variety of other behaviors that negatively impact response quality

   2.2. Select a similarity measure: Gower's dissimilarity coefficient is considered for a asymmetric binary data (source: https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_distance_sect003.htm)
  
   2.3. Select a clustering algorithm: 
     * Partitioning around medoids (PAM). Describe the iterative steps in PAM as following:
       + Choose k random entities to become the medoids
       + Assign every entity to its closest medoid (usign our custom distance matrix in this case)
       + For each cluster, identify the observation that woud yield the lowest average distance if it were to be re-assigned as the medoid. if so, make this observation the new medoid
       + If at least one medoid has changed, return to step 2. Otherwise, end the alg

     * Also consider k-means. However, PAM is more robust to noise and outliers when compared to k-means, and has the added benefit of having an observation serve as the exemplar for each clustser
      Both run time and memory are quadratic (i.e O(n^2))
      
   2.4. Select the number of clusters
   A variety of metrics exist to help choose the number of clusters: silhouette width, an internal validation metric which is aggregated measure of how similar an observation is to its own cluster compared its closest neighboring cluster. The metric can range from -1 to 1, where higher values are better. 
   Also use the scree plot to decide the number of custers to retain
  
   2.5. Visualize clusters in lower dimensional space
   Use t-distributed stochastic neighborhood embedding method to preserve local structure of the data such as to make clusters visible in a 2D or 3D visualization. 

   2.6. Assess the cluster stability
   I employed clusterboot algorithm, which uses the Jaccard coefficient to measure the similarity between sets generated over different bootstrap samples. The cluster stability of each cluster in the original clustering is the mean value of its Jaccard coefficient over all the bootstrap iterations. As a rule of thumb, clusters with a stability value less than 0.6 should be considered unstable. Values between 0.6 and 0.75 indicate that the cluster is measuring a pattern in the data, but there isn’t high certainty about which points should be clustered together. Clusters with stability values above about 0.85 can be considered highly stable (they’re likely to be real clusters).