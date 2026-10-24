INSERT INTO public.fact_customer_churn (
    customer_id,
    geography_id,
    demographic_id,
    product_profile_id,
    tenure_id,                                 
    credit_score,
    balance,
    estimated_salary,
    exited
)
SELECT DISTINCT ON (r.customer_id)
    r.customer_id,
    g.geography_id,
    d.demographic_id,
    p.product_profile_id,
    t.tenure_id,                               
    r.credit_score,
    r.balance,
    r.estimated_salary,
    r.churn AS exited
FROM public.raw_bank_churn r
JOIN public.dim_geography g 
  ON r.country = g.country_name
JOIN public.dim_demographics d 
  ON r.gender = d.gender 
 AND d.age_group = CASE 
        WHEN r.age < 25 THEN '<25'
        WHEN r.age BETWEEN 25 AND 35 THEN '25-35'
        WHEN r.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN r.age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
      END
JOIN public.dim_products p 
  ON r.products_number = p.products_number
 AND r.credit_card = p.credit_card
 AND r.active_member = p.active_member
JOIN public.dim_tenure t               
  ON r.tenure = t.tenure_years
ON CONFLICT (customer_id) DO NOTHING;