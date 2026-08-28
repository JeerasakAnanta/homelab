from datetime import datetime

from airflow.decorators import dag, task


@dag(
    dag_id="example_taskflow_dag",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["example", "taskflow"],
)
def taskflow_pipeline():

    @task
    def extract() -> list[dict]:
        # ในงานจริง: ดึงจาก API / DB / file
        return [
            {"id": 1, "amount": 100},
            {"id": 2, "amount": 250},
            {"id": 3, "amount": 75},
        ]

    @task
    def transform(records: list[dict]) -> list[dict]:
        # เพิ่ม field คำนวณ, กรองข้อมูล, clean
        for r in records:
            r["amount_with_vat"] = round(r["amount"] * 1.07, 2)
        return records

    @task
    def load(records: list[dict]) -> None:
        # ในงานจริง: insert เข้า DB / data warehouse
        for r in records:
            print(f"Loaded record: {r}")
        print(f"Total records loaded: {len(records)}")

    raw = extract()
    cleaned = transform(raw)
    load(cleaned)


taskflow_pipeline()
