# Data Source

The datasets used in this project are publicly available and were not included 
in this repository due to file size.

## Download Instructions

1. Go to Kaggle:
   - Intakes: https://www.kaggle.com/datasets/aaronschlegel/austin-animal-center-shelter-intakes-and-outcomes
   - Alternatively: https://data.austintexas.gov

2. Download both files:
   - Austin_Animal_Center_Intakes.csv
   - Austin_Animal_Center_Outcomes.csv

3. Place both files in this /data folder before running any SQL scripts.

## Loading Order

Run SQL scripts in the following order:
   1. 00_data_preparation.sql  — creates tables and imports data
   2. 01_churn_analysis.sql
   3. 02_adoption_cohorts.sql
   4. 03_recidivism_rates.sql
   5. 04_false_sweet_adoptions.sql
