from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

default_args = {
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='churn_dwh_pipeline',
    default_args=default_args,
    description='ETL пайплайн для наполнения DWH оттока клиентов',
    schedule_interval='@daily',
    start_date=datetime(2026, 1, 1),
    catchup=False,
    template_searchpath=['/opt/airflow/sql'],
) as dag:

    init_schema = SQLExecuteQueryOperator(
        task_id='init_schema_task',
        conn_id='postgres_dwh',
        sql='init_schema.sql',
    )

    fill_geography = SQLExecuteQueryOperator(
        task_id='fill_dim_geography',
        conn_id='postgres_dwh',
        sql='fill_dim_geography.sql',
    )

    fill_demographics = SQLExecuteQueryOperator(
        task_id='fill_dim_demographics',
        conn_id='postgres_dwh',
        sql='fill_dim_demographics.sql',
    )

    fill_products = SQLExecuteQueryOperator(
        task_id='fill_dim_products',
        conn_id='postgres_dwh',
        sql='fill_dim_products.sql',
    )

    
    fill_tenure = SQLExecuteQueryOperator(
        task_id='fill_dim_tenure',
        conn_id='postgres_dwh',
        sql='fill_dim_tenure.sql',
    )

    fill_fact = SQLExecuteQueryOperator(
        task_id='fill_fact_churn',
        conn_id='postgres_dwh',
        sql='fill_fact_churn.sql',
    )

    init_schema >> [fill_geography, fill_demographics, fill_products, fill_tenure] >> fill_fact