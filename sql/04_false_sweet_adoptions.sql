-- ==============================================================================
-- AAC Data Analysis - Step 4: "False Sweet Adoptions" (Puppy Effect)
-- Description: Analyzes adoptions of puppies (< 6 months) that resulted in 
-- returns to the shelter once the dog reached adulthood (>= 1 year).
-- Note: Indexes created to optimize the performance of the EXISTS subquery.
-- ==============================================================================

-- Optimize query performance for large datasets
CREATE INDEX idx_intakes_animal_id ON intakes(animal_id); 
CREATE INDEX idx_outcomes_animal_id ON outcomes(animal_id); 
 
SELECT   
    o.breed,  
      
    -- Base cohort: Total puppies adopted (< 0.5 years old) 
    COUNT(o.animal_id) AS total_puppy_adoptions,  
      
    -- Numerator: How many returned to the shelter as adults (>= 1 year old)  
    SUM(  
        CASE WHEN EXISTS (  
            SELECT 1   
            FROM intakes i   
            WHERE i.animal_id = o.animal_id  
            AND i.datetime > o.datetime   
            AND i.age_in_years >= 1.0   
        ) THEN 1 ELSE 0 END  
    ) AS returned_as_adults,  
      
    -- Calculate rejection/return rate  
    ROUND(  
        (SUM(  
            CASE WHEN EXISTS (  
                SELECT 1   
                FROM intakes i   
                WHERE i.animal_id = o.animal_id  
                AND i.datetime > o.datetime   
                AND i.age_in_years >= 1.0   
            ) THEN 1 ELSE 0 END  
        ) * 100.0) / COUNT(o.animal_id),   
    2) AS rejection_rate_percentage  
  
FROM outcomes o  
WHERE o.animal_type = 'Dog'  
AND o.outcome_type = 'Adoption'  
AND o.age_in_years < 0.5   
  
GROUP BY o.breed  
-- Ensure sample size is statistically significant
HAVING COUNT(o.animal_id) > 30  
ORDER BY rejection_rate_percentage DESC  
LIMIT 10;
