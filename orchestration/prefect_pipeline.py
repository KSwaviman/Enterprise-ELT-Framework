import os
import time

# Set environment variables before importing Prefect
os.environ["PREFECT_API_URL"] = "http://127.0.0.1:4200/api"
os.environ["PREFECT_LOGGING_LEVEL"] = "DEBUG"

# Now import Prefect and other modules
from prefect import flow, task
import subprocess
import requests
from requests.auth import HTTPBasicAuth
import logging
from prefect.logging import get_logger

logger = get_logger()
logger.setLevel(logging.DEBUG)

@task
def trigger_airbyte_sync():
    airbyte_url = "http://host.docker.internal:8000/api/v1/connections/sync"
    connection_id = "faeebcd1-a142-4815-aa01-5fdb4c84a779"
    
    username = "airbyte"  # Replace with your Airbyte username
    password = "password"  # Replace with your Airbyte password
    
    # Trigger Airbyte sync via API with Basic Authentication
    response = requests.post(
        airbyte_url, 
        json={"connectionId": connection_id}, 
        auth=HTTPBasicAuth(username, password)
    )
    
    if response.status_code == 200:
        logger.info("Airbyte sync triggered successfully")
    else:
        logger.error(f"Failed to trigger Airbyte sync: {response.status_code}, {response.text}")
        response.raise_for_status()

@task
def check_dbt_directory():
    # Check if the .dbt directory and profiles.yml exist
    dbt_dir = "/root/.dbt"
    profiles_path = os.path.join(dbt_dir, "profiles.yml")
    
    if os.path.exists(dbt_dir):
        logger.info(f"Directory '{dbt_dir}' exists.")
        if os.path.exists(profiles_path):
            logger.info(f"profiles.yml found in '{dbt_dir}'.")
        else:
            logger.error(f"profiles.yml not found in '{dbt_dir}'.")
    else:
        logger.error(f"Directory '{dbt_dir}' does not exist.")
    
    # Add a wait timer to ensure that everything is set up before running dbt
    logger.info("Waiting 15 seconds to ensure the environment is ready...")
    time.sleep(15)

@task
def run_dbt_via_subprocess():
    command = ["dbt", "run"]
    env = os.environ.copy()
    env["DBT_PROFILES_DIR"] = "/root/.dbt"  # Ensure the correct path
    
    try:
        result = subprocess.run(
            command, 
            cwd="/app", 
            env=env, 
            check=True, 
            text=True, 
            capture_output=True
        )
        logger.info("DBT Output:\n" + result.stdout)  # Log DBT output
        if result.stderr:
            logger.warning("DBT Errors:\n" + result.stderr)  # Log any DBT errors
    except subprocess.CalledProcessError as e:
        logger.error(f"Error running dbt: {e.stderr}")  # Log the detailed dbt error
        logger.error(f"DBT Command Output:\n{e.output}")
        raise


@flow
def elt_pipeline():
    trigger_airbyte_sync()
    check_dbt_directory()  # Add this task to check the .dbt directory and profiles.yml
    run_dbt_via_subprocess()

# Run the flow
if __name__ == "__main__":
    elt_pipeline()
