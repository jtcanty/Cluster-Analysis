## STORM/PALM analysis
This repository contains various scripts for analyzing STORM/PALM cluster data. The scripts should be used in conjuction with the Insight Software package (Copyright Bo Huang, UCSF).

## Description of subroutines
Assuming that a super-resolution data-set has been collected using Insight and that telomere clusters have been identified and saved as .txt files.

RipleyK.m: Applies the Ripley-K algorithm to each .txt file and identifies spots with the highest k-values. An ROI is defined
           around these spots which contains the cluster to be analyzed.
           
Telomere_Cluster.m: Iterates over outputted RipleyK files and allows the user to subtract noise manually. The area and number
                    of localizations are determined for each cluster and saved in .xlsx
                      
Merge_Excel.m: Merges all outputted excel files within a folder

