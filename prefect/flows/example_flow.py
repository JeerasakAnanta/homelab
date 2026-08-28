"""Example Prefect flow.

This file is bind-mounted into the prefect-flows container. `serve()` registers a
deployment against the server and runs it on the schedule below — restart the
prefect-flows service after editing to pick up changes.
"""

from prefect import flow, get_run_logger, task


@task
def build_greeting(name: str) -> str:
    get_run_logger().info("building greeting for %s", name)
    return f"hello, {name}"


@flow(name="hello-homelab")
def hello_homelab(name: str = "homelab") -> str:
    greeting = build_greeting(name)
    get_run_logger().info(greeting)
    return greeting


if __name__ == "__main__":
    hello_homelab.serve(
        name="hello-homelab",
        interval=3600,  # run once an hour
    )
