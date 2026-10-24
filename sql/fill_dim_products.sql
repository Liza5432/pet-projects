INSERT INTO public.dim_products (products_number, credit_card, active_member)
SELECT DISTINCT 
    products_number,
    credit_card,
    active_member
FROM public.raw_bank_churn
ON CONFLICT DO NOTHING;