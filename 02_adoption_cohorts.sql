-- ==============================================================================
-- AAC Data Analysis - Step 2: Time-to-Adoption Cohort Analysis
-- Description: Categorizes intakes into cohorts (YYYY-QQ) and calculates 
-- adoption velocity (days until adopted) using epoch extraction.
-- ==============================================================================

WITH FutureOutcomes AS (    
    SELECT    
        i.animal_id,     
        i.datetime AS intake_date,    
        o.datetime AS next_outcome_date,   
        o.outcome_type,  
           
        -- Rank subsequent outcomes to find the first event after intake    
        ROW_NUMBER() OVER(    
            PARTITION BY i.animal_id, i.datetime    
            ORDER BY o.datetime ASC    
        ) as event_rank        
  
    FROM intakes i    
    LEFT JOIN outcomes o  
        ON i.animal_id = o.animal_id    
        AND i.datetime < o.datetime   
           
    -- Exclude wildlife as they are not candidates for standard adoption  
    WHERE i.intake_type != 'Wildlife'   
)
  
SELECT   
    animal_id,  
      
    -- Group intakes into quarterly cohorts (e.g., '2014-Q1')  
    TO_CHAR(intake_date, 'YYYY-"Q"Q') AS intake_cohort,  
      
    -- Categorize adoption velocity into standard time buckets  
    CASE   
        WHEN outcome_type != 'Adoption' OR outcome_type IS NULL THEN '0_No_adoption'  
        WHEN EXTRACT(EPOCH FROM (next_outcome_date - intake_date)) / 86400.0 <= 7 THEN '1_Within_7_days'  
        WHEN EXTRACT(EPOCH FROM (next_outcome_date - intake_date)) / 86400.0 <= 14 THEN '2_Within_14_days'  
        WHEN EXTRACT(EPOCH FROM (next_outcome_date - intake_date)) / 86400.0 <= 30 THEN '3_Within_30_days'  
        ELSE '4_Over_30_days'  
    END AS when_adoption  
  
FROM FutureOutcomes  
WHERE event_rank IS NULL OR event_rank = 1;