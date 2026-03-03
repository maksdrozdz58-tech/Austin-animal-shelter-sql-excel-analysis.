-- ==============================================================================
-- AAC Data Analysis - Step 1: 180-Day Adoption Churn
-- Description: Identifies adoptions that resulted in a return to the shelter 
-- within a 180-day window using Window Functions.
-- ==============================================================================

WITH FutureIntakes AS (   
    SELECT    
        o.animal_id,   
        o.animal_type,   
        o.breed,   
        o.color,   
        o.age_in_years,  
        o.sex_upon_outcome,   
        o.outcome_subtype,   
            
        o.datetime AS adoption_date,   
        i.datetime AS next_intake_date,   
        i.intake_type AS return_type,   
            
        -- Rank subsequent intakes to find the immediate next return   
        ROW_NUMBER() OVER(   
            PARTITION BY o.animal_id, o.datetime    
            ORDER BY i.datetime ASC   
        ) as event_rank   
            
    FROM outcomes o  
    LEFT JOIN intakes i    
        ON o.animal_id = i.animal_id    
        AND i.datetime > o.datetime   
    WHERE o.outcome_type = 'Adoption'   
)   
SELECT    
    animal_id,   
    animal_type,   
    breed,   
    color,   
    age_in_years,  
    sex_upon_outcome,   
    outcome_subtype,   
    adoption_date,   
    next_intake_date,   
    return_type,   
        
    -- Flag adoptions that failed within 180 days (Churn)
    CASE    
        WHEN next_intake_date IS NULL THEN 0    
        WHEN next_intake_date - adoption_date <= INTERVAL '180 days' THEN 1    
        ELSE 0    
    END AS churn_180_days_flag   
    
FROM FutureIntakes   
WHERE event_rank = 1;
