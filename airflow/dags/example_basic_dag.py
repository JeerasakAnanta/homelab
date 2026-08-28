from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator


def say_hello():
    print("Hello from Airflow!")


def process_data():
    data = [1, 2, 3, 4, 5]
    total = sum(data)
    print(f"Sum = {total}")
    return total


with DAG(
    dag_id="example_basic_dag",
    start_date=datetime(2024, 1, 1),
    # กด Trigger เองตอนทดสอบ ไม่ต้องรอ cron
    schedule=None,
    catchup=False,
    tags=["example"],
) as dag:

    task_hello = PythonOperator(
        task_id="say_hello",
        python_callable=say_hello,
    )

    task_process = PythonOperator(
        task_id="process_data",
        python_callable=process_data,
    )

    task_hello >> task_process
