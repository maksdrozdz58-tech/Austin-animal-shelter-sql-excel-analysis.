-- ==============================================================================
-- AAC Data Analysis - Step 3: Recidivism by Breed
-- Description: Identifies dog breeds with the highest probability of multiple 
-- returns to the shelter (recidivism). Filtered for statistical significance.
-- ==============================================================================

WITH intake_count_per_dog AS (  
    SELECT   
        animal_id,  
        breed,  
        COUNT(datetime) AS no_intakes  
    FROM intakes  
    WHERE animal_type = 'Dog'  
    GROUP BY animal_id, breed  
)  
SELECT   
    breed,  
    COUNT(animal_id) AS no_dogs,  
    ROUND(AVG(no_intakes), 2) AS average_no_intakes,  
    MAX(no_intakes) AS max_no_intakes,  
      
    -- Count distinct dogs that returned 2 or more times  
    SUM(CASE WHEN no_intakes > 1 THEN 1 ELSE 0 END) AS no_dogs_with_at_least_2_intakes,   
      
    -- Calculate overall recidivism rate per breed  
    ROUND(  
        (SUM(CASE WHEN no_intakes > 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(animal_id),   
    2) AS recidivism_percentage  
  
FROM intake_count_per_dog  
GROUP BY breed  
-- Ensure sample size is statistically significant (>30 individuals)
HAVING COUNT(animal_id) > 30  
ORDER BY recidivism_percentage DESC;
