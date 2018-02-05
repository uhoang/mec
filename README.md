# Consumer lifestyle segmentation

This project was built in R language for the data team at Moutain Equipment Coorporation. Sharing outputs have been de-identified to protect individual privacy.

### Repository's structure

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
- Build consumer health lifestyle segmentation based on respondents' age, current health condition and the conditions they like to prevent in the future
- Identify clusters and intepret its meaning via descriptive statistics
- Provide titbits through profile questions on lifestyle and social demographics
- Future work: prototype a lifestyle scoring tool to predict a class / segment for a new consumer

### Methods
1. Inputs:
  - A multiple-select question on health condition and prevention is converted to a set of binary variables. Each binary variable represents one category in the question. The varible is coded 1 if the category is selected and 0 otherwise. 
  - Age is a continuous variable, and has a range from 18 to 70 years old. 

2. Analysis:

   2.1. Data quality control: <br/>
   &nbsp;&nbsp;&nbsp; We remove any low-quality observation, in which a respondent speeds through the survey by giving low-effort responses, and engages in variety of other behaviors that negatively impact response quality.

   2.2. Transform inputs: <br/>
   &nbsp;&nbsp;&nbsp; We group some health/prevention conditions into category to reduce the complexity of the inputs. This step helps to produce a cleaner interpretation of clusters in a later step. 
   
   2.3. Select a similarity measure: <br/>
   &nbsp;&nbsp;&nbsp; To group observations together, we first need to define some notion of similarity between observations. Since the data contains nominal variables, we will use a distance metric called Gower distance. The distance is always a number between 0 (idential) and 1 (maximally dissimilar). When all vairables are binary (with asymmetric significance of categories: 'present' vs 'absent' attribute), then gower uses Jaccard matching coefficient to measure the distance.  
  
   2.4. Select a clustering algorithm: 
     * We apply both PAM and k-means algorithm for clustering. It is known that PAM is more robust to noise and outliers when compared to k-means, and it has the added benefit of having an observation serve as the exemplar for each cluster. Both algorithms have quadratic run time and memory (i.e: O(n^2))
     
     * Explain how Partitioning around medoids (PAM) works
       + Choose k random entities to become the medoids
       + Assign every entity to its closest medoid (usign our custom distance matrix in this case)
       + For each cluster, identify the observation that woud yield the lowest average distance if it were to be re-assigned as the medoid. if so, make this observation the new medoid
       + If at least one medoid has changed, return to the second step. Otherwise, end the algorithm
      
   2.4. Select the number of clusters <br/>
   &nbsp;&nbsp;&nbsp; A variety of metrics exist to help choose the number of clusters. In this analysis, we use Silhouette width, an internal validation metric. It is an aggregated measure of how similar an observation is to its own cluster compared its closest neighboring cluster. The metric can range from -1 to 1, where higher values are better. We then plot silhouette width for clusters ranging from 2 to 10 for the PAM algorithm. Even two clusters have the highest Silhouette width, we want to keep the diverse number of clusters for more interesting interpretation.
  
   2.5. Visualize clusters in lower dimensional space <br/>
   &nbsp;&nbsp;&nbsp; Use t-distributed stochastic neighborhood embedding method to preserve local structure of the data such as to make clusters visible in a 2D or 3D visualization. 

   2.6. Assess the cluster stability <br/>
   &nbsp;&nbsp;&nbsp; I employed clusterboot algorithm, which uses the Jaccard coefficient to measure the similarity between sets generated over different bootstrap samples. The cluster stability of each cluster in the original clustering is the mean value of its Jaccard coefficient over all the bootstrap iterations. As a rule of thumb, clusters with a stability value less than 0.6 should be considered unstable. Values between 0.6 and 0.75 indicate that the cluster is measuring a pattern in the data, but there isn’t high certainty about which points should be clustered together. Clusters with stability values above about 0.85 can be considered highly stable (they’re likely to be real clusters).