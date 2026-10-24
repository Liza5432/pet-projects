DROP TABLE IF EXISTS fact_customer_churn CASCADE;
DROP TABLE IF EXISTS dim_geography CASCADE;
DROP TABLE IF EXISTS dim_demographics CASCADE;
DROP TABLE IF EXISTS dim_products CASCADE;
DROP TABLE IF EXISTS dim_tenure CASCADE;   


CREATE TABLE dim_geography (
    geography_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE
);

INSERT INTO dim_geography (country_name)
SELECT DISTINCT country 
FROM raw_bank_churn 
WHERE country IS NOT NULL;


CREATE TABLE dim_demographics (
    demographic_id SERIAL PRIMARY KEY,
    gender VARCHAR(20),
    age_group VARCHAR(20),
    CONSTRAINT uq_demographics_gender_age UNIQUE (gender, age_group)
);

INSERT INTO dim_demographics (gender, age_group)
SELECT DISTINCT 
    gender,
    CASE 
        WHEN age < 25 THEN '<25'
        WHEN age BETWEEN 25 AND 35 THEN '25-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group
FROM raw_bank_churn;


CREATE TABLE dim_products (
    product_profile_id SERIAL PRIMARY KEY,
    products_number INT,
    credit_card INT,
    active_member INT,
    CONSTRAINT uq_products_profile UNIQUE (products_number, credit_card, active_member)
);

INSERT INTO dim_products (products_number, credit_card, active_member)
SELECT DISTINCT 
    products_number, 
    credit_card, 
    active_member 
FROM raw_bank_churn;



CREATE TABLE dim_tenure (
    tenure_id SERIAL PRIMARY KEY,
    tenure_years INT UNIQUE,
    tenure_group VARCHAR(10),
    tenure_group_order INT
);

INSERT INTO dim_tenure (tenure_years, tenure_group, tenure_group_order)
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
FROM raw_bank_churn
WHERE tenure IS NOT NULL;


CREATE TABLE fact_customer_churn AS
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
FROM raw_bank_churn r
LEFT JOIN dim_geography g ON r.country = g.country_name
LEFT JOIN dim_products p ON r.products_number = p.products_number AND r.credit_card = p.credit_card 
AND r.active_member = p.active_member
LEFT JOIN dim_tenure t ON r.tenure = t.tenure_years      
LEFT JOIN dim_demographics d ON r.gender = d.gender 
    AND d.age_group = CASE 
            WHEN r.age < 25 THEN '<25'
            WHEN r.age BETWEEN 25 AND 35 THEN '25-35'
            WHEN r.age BETWEEN 36 AND 45 THEN '36-45'
            WHEN r.age BETWEEN 46 AND 60 THEN '46-60'
            ELSE '60+'
        END;

ALTER TABLE fact_customer_churn ADD PRIMARY KEY (customer_id);
ALTER TABLE fact_customer_churn 
ADD CONSTRAINT fk_fact_geography FOREIGN KEY (geography_id) REFERENCES dim_geography(geography_id),
ADD CONSTRAINT fk_fact_demographics FOREIGN KEY (demographic_id) REFERENCES dim_demographics(demographic_id),
ADD CONSTRAINT fk_fact_products FOREIGN KEY (product_profile_id) REFERENCES dim_products(product_profile_id),
ADD CONSTRAINT fk_fact_tenure FOREIGN KEY (tenure_id) REFERENCES dim_tenure(tenure_id);   