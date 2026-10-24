# Bank Customer Churn: DWH на PostgreSQL + Airflow и BI-дашборд на Power BI
## Этапы выполнения проекта:
### 1. Проектирование модели данных
Я взяла датасет Bank Customer Churn Prediction (Kaggle): около 10 000 клиентов банка из Франции, Германии и Испании. Исходные данные лежат в таблице raw_bank_churn.
Разделила датасет на таблицу фактов fact_customer_churn (клиент, показатели, признак оттока) и четыре измерения: dim_geography (страна), dim_demographics (пол и возраст), dim_products (продукты и активность) и dim_tenure (стаж) и таким образом спроектировала схему «звезда»:
<img width="1367" height="888" alt="image" src="https://github.com/user-attachments/assets/dbc5f4e7-13b6-4ca8-a43a-64231043166f" />

### 2. Оркестрация пайплайна в Apache Airflow
Настроила оркестрацию: окружение поднимается через Docker Compose, а загрузка DWH описана DAG'ом churn_dwh_pipeline из шести задач:
<img width="2131" height="1065" alt="image" src="https://github.com/user-attachments/assets/09505fea-579c-4836-831a-abbd68603aab" />
**DAG в Airflow**
1. init_schema_task создаёт таблицы DWH и выполняет первичную загрузку (sql/init_schema.sql).
2. Параллельно выполняются fill_dim_geography, fill_dim_demographics, fill_dim_products и fill_dim_tenure, которые заполняют таблицы измерений.
3. После всех измерений fill_fact_churn загружает таблицу фактов с подстановкой ключей измерений.

### 3. BI-Дашборд в Power BI
Загрузила данные из DWH в Power BI и создала дашборд:
Страница 1. Ключевые показатели, отток по странам и полу:

<img width="2011" height="1008" alt="image" src="https://github.com/user-attachments/assets/074bfd0c-6135-44d3-b588-26e1dc6d39d9" />
Страница 2. Отток по возрасту, числу продуктов, стажу и активности, матрица относительного риска «возраст × страна»:

<img width="2026" height="1125" alt="image" src="https://github.com/user-attachments/assets/fd053ad7-a178-4318-8e20-9fb35b0ef3e0" />
Страница 3.  Баланс ушедших клиентов, диаграмма Парето по возрасту, потери по странам:

<img width="2052" height="1120" alt="image" src="https://github.com/user-attachments/assets/f5440d49-341d-4ecb-bec5-e65ef2185765" />


