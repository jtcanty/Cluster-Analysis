# Cluster-Analysis

## Code for analyzing telomere super-resolution data from either STORM or PALM
* This code consists of several scripts for analyzing telomere clusters obtained from STORM or PALM data. 
* This code is used in conjuction with the Insight Software (Copyright Bo Huang)

##  Information on contained functions
* Assuming that a super-resolution data-set has been collected using Insight and that telomere clusters have been identified
  and saved as .txt files.
  
  RipleyK.m: Applys the Ripley-K algorithm to each .txt file and identifies spots with the highest k-values. An ROI is defined
             around these spots which contains the cluster to be analyzed.
  
  Telomere_Cluster.m: Iterates over outputted RipleyK files and allows the user to subtract noise manually. The area and number
                      of localizations are determined for each cluster and saved in .xlsx
                      
  Merge_Excel.m: Merges all outputted excel files within a folder

