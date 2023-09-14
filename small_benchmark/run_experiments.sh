#!/bin/bash

source ~/.bashrc
conda activate pygeo39

module load cuda11.3/toolkit/11.3.1
module load cuDNN/cuda11.1/8.0.5

# Define an array of dataset names
datasets=("cora" "citeseer" "pubmed" "reddit" "flickr" "yelp" "arxiv" "products")

# Output CSV header
echo "Dataset,Mean,Standard Deviation,Memory Usage (point1) Mean,Memory Usage (point1) Std Dev,Memory Usage (point2) Mean,Memory Usage (point2) Std Dev" > results.csv

# Loop through each dataset and perform tasks
for dataset_name in "${datasets[@]}"
do
    # Print multiple newlines and the dataset name
    echo -e "\n\nProcessing ${dataset_name}\n\n"

    # Step 1: Run the python command and redirect the output to a file
    python main.py model=gcn dataset=${dataset_name} root=/var/scratch/tsingam/ > ${dataset_name}.output

    # Step 2: Extract the mean, standard deviation, and memory usages
    acc_line=$(tail -n 3 ${dataset_name}.output | head -n 1)
    memory_point1_line=$(tail -n 2 ${dataset_name}.output | head -n 1)
    memory_point2_line=$(tail -n 1 ${dataset_name}.output)
    
    mean=$(echo $acc_line | awk '{print $3}')
    std_dev=$(echo $acc_line | awk '{print $5}')
    
    memory_point1_mean=$(echo $memory_point1_line | awk '{print $3}')
    memory_point1_std_dev=$(echo $memory_point1_line | awk '{print $5}')
    memory_point2_mean=$(echo $memory_point2_line | awk '{print $3}')
    memory_point2_std_dev=$(echo $memory_point2_line | awk '{print $5}')

    # Remove the ± symbols
    std_dev_cleaned=${std_dev//±/}
    memory_point1_std_dev_cleaned=${memory_point1_std_dev//±/}
    memory_point2_std_dev_cleaned=${memory_point2_std_dev//±/}

    # Step 3: Store the results to the CSV
    echo "${dataset_name},${mean},${std_dev_cleaned},${memory_point1_mean},${memory_point1_std_dev_cleaned},${memory_point2_mean},${memory_point2_std_dev_cleaned}" >> results.csv
done

# Print the results
cat results.csv

