INSERT INTO public.dim_tenure (tenure_years, tenure_group, tenure_group_order)
SELECT DISTINCT
    tenure,
    CASE
        WHEN tenure <= 2 THEN '0-2'
        WHEN tenure <= 5 THEN '3-5'
        WHEN tenure <= 8 THEN '6-8'
        ELSE '9+'
    END,
    CASE
        WHEN tenure <= 2 THEN 1
        WHEN tenure <= 5 THEN 2
        WHEN tenure <= 8 THEN 3
        ELSE 4
    END
FROM public.raw_bank_churn
WHERE tenure IS NOT NULL
ON CONFLICT (tenure_years) DO NOTHING;