-- ==============================================================================
-- AAC Data Analysis - Step 0: Data Preparation & Cleaning
-- Description: Creating base tables, standardizing datetime formats (ISO 8601), 
-- and extracting numeric age values from raw text strings.
-- ==============================================================================

-- 1. Create base tables for raw data import
CREATE TABLE intakes ( 
    age_upon_intake VARCHAR(100), 
    animal_id VARCHAR(100), 
    animal_type VARCHAR(100), 
    breed VARCHAR(300), 
    color VARCHAR(300), 
    datetime VARCHAR(100), 
    datetime2 VARCHAR(100), 
    found_location VARCHAR(300), 
    intake_condition VARCHAR(100), 
    intake_type VARCHAR(100), 
    name VARCHAR(100), 
    sex_upon_intake VARCHAR(100) 
); 

CREATE TABLE outcomes ( 
    age_upon_outcome VARCHAR(100), 
    animal_id VARCHAR(100), 
    animal_type VARCHAR(100), 
    breed VARCHAR(300), 
    color VARCHAR(300), 
    date_of_birth VARCHAR(100), 
    datetime VARCHAR(100), 
    monthyear VARCHAR(100), 
    name VARCHAR(100), 
    outcome_subtype VARCHAR(100), 
    outcome_type VARCHAR(100), 
    sex_upon_outcome VARCHAR(100) 
); 

-- 2. Standardize datetime columns to proper TIMESTAMP format
ALTER TABLE intakes ALTER COLUMN datetime TYPE TIMESTAMP USING datetime::TIMESTAMP; 
ALTER TABLE outcomes ALTER COLUMN datetime TYPE TIMESTAMP USING datetime::TIMESTAMP; 

-- 3. Extract precise age in years from text formats (e.g., "2 years", "3 months")
-- Adding column to intakes
ALTER TABLE intakes ADD COLUMN age_in_years NUMERIC; 

UPDATE intakes 
SET age_in_years = ROUND( 
    CAST(NULLIF(SPLIT_PART(age_upon_intake, ' ', 1), '') AS NUMERIC) * CASE  
        WHEN age_upon_intake LIKE '%year%' THEN 1.0 
        WHEN age_upon_intake LIKE '%month%' THEN 1.0 / 12.0 
        WHEN age_upon_intake LIKE '%week%' THEN 1.0 / 52.0 
        WHEN age_upon_intake LIKE '%day%' THEN 1.0 / 365.0 
        ELSE 0  
    END,  
2) 
WHERE age_upon_intake IS NOT NULL; 

-- Adding column to outcomes
ALTER TABLE outcomes ADD COLUMN age_in_years NUMERIC; 

UPDATE outcomes  
SET age_in_years = ROUND(  
    CAST(NULLIF(SPLIT_PART(age_upon_outcome, ' ', 1), '') AS NUMERIC) * CASE   
        WHEN age_upon_outcome LIKE '%year%' THEN 1.0  
        WHEN age_upon_outcome LIKE '%month%' THEN 1.0 / 12.0  
        WHEN age_upon_outcome LIKE '%week%' THEN 1.0 / 52.0  
        WHEN age_upon_outcome LIKE '%day%' THEN 1.0 / 365.0  
        ELSE 0   
    END,   
2)  
WHERE age_upon_outcome IS NOT NULL  
AND age_upon_outcome != 'NULL';