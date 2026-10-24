INSERT INTO public.dim_geography (country_name)
SELECT DISTINCT country
FROM public.raw_bank_churn
WHERE country IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;