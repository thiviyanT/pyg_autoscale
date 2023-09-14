#!/bin/bash

source ~/.bashrc
conda activate pygeo39

module load cuda11.3/toolkit/11.3.1
module load cuDNN/cuda11.1/8.0.5

# Define an array of dataset names
datasets=("cora" "citeseer" "pubmed" "reddit" "flickr" "yelp" "arxiv" "products")

# Output CSV header
echo "Dataset,Mean,Standard Deviation" > results.csv

# Loop through each dataset and perform tasks
for dataset_name in "${datasets[@]}"
do
    # Print multiple newlines and the dataset name
    echo -e "\n\nProcessing ${dataset_name}\n\n"

    # Step 1: Run the python command and redirect the output to a file
    python main.py model=gcn dataset=${dataset_name} root=/var/scratch/tsingam/ > ${dataset_name}.output

    # Step 2: Extract the mean and standard deviation from the last line
    last_line=$(tail -n 1 ${dataset_name}.output)
    mean=$(echo $last_line | awk '{print $3}')
    std_dev=$(echo $last_line | awk '{print $5}')

    # Remove the ± symbol
    std_dev_cleaned=${std_dev//±/}

    # Step 3: Store the mean and standard deviation to the CSV
    echo "${dataset_name},${mean},${std_dev_cleaned}" >> results.csv
done

# Print the results
cat results.csv
