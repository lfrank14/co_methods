# co_methods
This project contains the code for...
1) General preprocessing of fMRI brain images on the University of Oregon's high-performance computing cluster
2) Removing task-related activations from fMRI brain activity using-  a) low-pass filtering to remove task-related frequencies from the brain signal, and b) extracting the residuals of a general linear model of task-related events
3) Calculating region-to-region resting-state connectivity and background connectivity using each of the methods for removing task-related activity
4) Comparing connectivity between the two background connectivity methods to see which is better for reproducing resting-state connectivity patterns
