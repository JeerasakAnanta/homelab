"""Example Dagster code location.

Edit this file (it is bind-mounted into the dagster-code container) and reload the
"example" code location from the UI — no rebuild needed.
"""

from dagster import (
    Definitions,
    ScheduleDefinition,
    asset,
    define_asset_job,
    get_dagster_logger,
)


@asset
def hello_world() -> str:
    get_dagster_logger().info("materializing hello_world")
    return "hello, homelab"


@asset
def greeting(hello_world: str) -> str:
    return f"{hello_world}!"


daily_refresh = define_asset_job("daily_refresh", selection="*")

defs = Definitions(
    assets=[hello_world, greeting],
    jobs=[daily_refresh],
    schedules=[
        ScheduleDefinition(job=daily_refresh, cron_schedule="0 6 * * *"),
    ],
)
