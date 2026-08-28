from datetime import datetime, timedelta

from airflow.decorators import dag, task

default_args = {
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}


@dag(
    dag_id="example_etl_postgres_dag",
    start_date=datetime(2024, 1, 1),
    schedule="0 6 * * *",  # ทุกวัน 06:00
    catchup=False,
    default_args=default_args,
    tags=["example", "etl", "postgres"],
)
def etl_postgres_pipeline():
    """
    ตัวอย่าง pipeline แบบใกล้เคียงงานจริง:
    ต้องมี Postgres connection ชื่อ 'postgres_default' (หรือสร้าง connection
    ใหม่ใน Airflow UI: Admin > Connections) ที่ชี้ไปยัง DB ปลายทาง
    """

    @task
    def extract_from_source() -> list[dict]:
        # จำลองข้อมูลจากระบบต้นทาง (แทนที่ด้วย API call / query จริง)
        return [
            {"customer_id": 101, "revenue": 5000},
            {"customer_id": 102, "revenue": 3200},
        ]

    @task
    def transform_data(rows: list[dict]) -> list[dict]:
        for r in rows:
            r["revenue_thb"] = r["revenue"] * 1.0  # placeholder transform
        return rows

    @task
    def load_to_postgres(rows: list[dict]) -> None:
        from airflow.providers.postgres.hooks.postgres import PostgresHook

        hook = PostgresHook(postgres_conn_id="postgres_default")
        create_sql = """
        CREATE TABLE IF NOT EXISTS customer_revenue (
            customer_id INT PRIMARY KEY,
            revenue_thb NUMERIC
        );
        """
        hook.run(create_sql)

        insert_sql = """
        INSERT INTO customer_revenue (customer_id, revenue_thb)
        VALUES (%s, %s)
        ON CONFLICT (customer_id) DO UPDATE
        SET revenue_thb = EXCLUDED.revenue_thb;
        """
        for r in rows:
            hook.run(insert_sql, parameters=(r["customer_id"], r["revenue_thb"]))

    raw = extract_from_source()
    cleaned = transform_data(raw)
    load_to_postgres(cleaned)


etl_postgres_pipeline()
