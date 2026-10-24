INSERT INTO public.dim_demographics (gender, age_group)
SELECT DISTINCT 
    gender,
    CASE 
        WHEN age < 25 THEN '<25'
        WHEN age BETWEEN 25 AND 35 THEN '25-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group
FROM public.raw_bank_churn
WHERE gender IS NOT NULL
ON CONFLICT DO NOTHING;